require "test_helper"

class AdminPostsTest < ActionDispatch::IntegrationTest
  AUTH = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("tsoi", "changeme") }.freeze
  UPLOAD_DIR = Rails.root.join("public", "images", "blog")

  setup { Post.delete_all }

  teardown do
    Dir.glob(UPLOAD_DIR.join("test-upload*")).each { |f| File.delete(f) }
  end

  test "requires admin login" do
    get "/admin/posts/new"
    assert_response :unauthorized
    post "/admin/posts/images"
    assert_response :unauthorized
  end

  test "the form shows the nine categories and the seo fields" do
    get "/admin/posts/new", headers: AUTH
    assert_response :success
    doc = Nokogiri::HTML5(response.body)
    options = doc.css("#post_category option").map(&:text).reject { |t| t.start_with?("—") }
    assert_equal Post::CATEGORIES, options
    %w[post_meta_title post_meta_description post_json_ld post_cover_image_alt blog-images-input].each do |id|
      assert doc.at("##{id}"), "missing ##{id}"
    end
  end

  test "creates a draft with seo fields; nothing auto-publishes" do
    post "/admin/posts", headers: AUTH, params: { post: {
      title: "New One", body: "## Hi", category: "School Selection",
      meta_title: "Meta", meta_description: "Desc", cover_image_alt: "Alt",
      json_ld: '<script type="application/ld+json">{"@type":"Article"}</script>'
    } }
    assert_redirected_to "/admin/posts"
    p = Post.find_by!(slug: "new-one")
    assert_not p.published?
    assert_equal({ "@type" => "Article" }, JSON.parse(p.json_ld))
    assert_equal "Meta", p.meta_title
  end

  test "rejects invalid json-ld and unknown categories" do
    post "/admin/posts", headers: AUTH, params: { post: { title: "Bad", json_ld: "{not json", category: "Nope" } }
    assert_response :unprocessable_entity
    assert_includes response.body, "Json ld is not valid JSON"
    assert_includes response.body, "Category is not included in the list"
  end

  test "older posts keep a legacy category when edited" do
    legacy = Post.create!(title: "Legacy")
    legacy.update_column(:category, "News")
    get "/admin/posts/#{legacy.slug}/edit", headers: AUTH
    assert_response :success
    assert_includes response.body, "News (old category)"
    patch "/admin/posts/#{legacy.slug}", headers: AUTH, params: { post: { title: "Legacy edited", category: "News" } }
    assert_redirected_to "/admin/posts"
    assert_equal "News", legacy.reload.category
  end

  test "edit and delete work from the slug-based admin links" do
    p = Post.create!(title: "Linked Post")
    get edit_admin_post_path(p), headers: AUTH
    assert_response :success
    delete admin_post_path(p), headers: AUTH
    assert_redirected_to "/admin/posts"
    assert_not Post.exists?(p.id)
  end

  test "uploads images to public/images/blog and rejects non-images" do
    png = Rack::Test::UploadedFile.new(StringIO.new("\x89PNG\r\n\x1A\n".b + "0" * 20), "image/png", true, original_filename: "Test Upload-infographic.png")
    fake = Rack::Test::UploadedFile.new(StringIO.new("<svg onload=alert(1)>"), "image/png", false, original_filename: "test-upload-evil.png")
    exe = Rack::Test::UploadedFile.new(StringIO.new("x"), "text/html", false, original_filename: "test-upload.html")

    post "/admin/posts/images", headers: AUTH, params: { images: [ png, fake, exe ] }
    assert_response :success
    images = response.parsed_body["images"]

    assert_equal "/images/blog/test-upload-infographic.png", images[0]["url"]
    assert_equal "Test upload", images[0]["alt"]
    assert File.exist?(UPLOAD_DIR.join("test-upload-infographic.png"))
    assert_match "not a valid PNG", images[1]["error"]
    assert_match "Only JPG, PNG", images[2]["error"]
    assert_not File.exist?(UPLOAD_DIR.join("test-upload-evil.png"))
  end
end
