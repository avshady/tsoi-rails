require "test_helper"

class AdminPostImportsTest < ActionDispatch::IntegrationTest
  AUTH = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("tsoi", "changeme") }.freeze
  UPLOAD_DIR = Rails.root.join("public", "images", "blog")
  IMG = %w[cbse-affiliation-hero cbse-affiliation-steps-infographic cbse-affiliation-costs-infographic].freeze

  setup { Post.where(slug: "cbse-affiliation-process").destroy_all }

  teardown do
    (IMG + %w[stray]).each { |n| File.delete(UPLOAD_DIR.join("#{n}.png")) if File.exist?(UPLOAD_DIR.join("#{n}.png")) }
  end

  def md(**over)
    text = file_fixture("cbse-affiliation-admin-upload.md").read
    over.each { |label, body| text = text.sub(/(^\#\# #{Regexp.escape(label.to_s)}\n).*?(?=\n\#\# |\z)/m, "\\1#{body}\n") }
    Rack::Test::UploadedFile.new(StringIO.new(text), "text/markdown", original_filename: "cbse-affiliation-admin-upload.md")
  end

  def img(name)
    Rack::Test::UploadedFile.new(file_fixture("#{name}.png").to_s, "image/png", original_filename: "#{name}.png")
  end

  def all_images
    IMG.map { |n| img(n) }
  end

  test "requires admin login" do
    get "/admin/posts/import"
    assert_response :unauthorized
    post "/admin/posts/import"
    assert_response :unauthorized
  end

  test "imports the sample package as a draft and lands on Edit" do
    assert_difference -> { Post.count }, 1 do
      post "/admin/posts/import", headers: AUTH, params: { package: md, images: all_images }
    end
    post_record = Post.find_by!(slug: "cbse-affiliation-process")
    assert_redirected_to edit_admin_post_path(post_record)

    assert_not post_record.published?, "import must never publish"
    assert_nil post_record.publish_at, "publish_at must be left nil"
    assert_equal "School Operations", post_record.category
    assert_equal "/images/blog/cbse-affiliation-hero.png", post_record.cover_image
    assert_match "CBSE logo", post_record.cover_image_alt
    assert_equal "Article", JSON.parse(post_record.json_ld)["@type"]
    assert_includes post_record.body, "/images/blog/cbse-affiliation-steps-infographic.png"

    # Every referenced image is on disk, so the body tags resolve.
    IMG.each { |n| assert File.exist?(UPLOAD_DIR.join("#{n}.png")), "#{n}.png not stored" }
  end

  test "rejects an unrecognized category with a clear error and creates nothing" do
    assert_no_difference -> { Post.count } do
      post "/admin/posts/import", headers: AUTH, params: { package: md(CATEGORY: "Sports"), images: all_images }
    end
    assert_response :unprocessable_entity
    assert_match "is not one of", response.body
  end

  test "rejects invalid JSON-LD" do
    assert_no_difference -> { Post.count } do
      post "/admin/posts/import", headers: AUTH, params: { package: md("JSON-LD": "{broken"), images: all_images }
    end
    assert_response :unprocessable_entity
    assert_match "not valid JSON", response.body
  end

  test "flags an uploaded image that the package does not reference" do
    stray = Rack::Test::UploadedFile.new(file_fixture("cbse-affiliation-hero.png").to_s, "image/png", original_filename: "stray.png")
    assert_no_difference -> { Post.count } do
      post "/admin/posts/import", headers: AUTH, params: { package: md, images: all_images + [ stray ] }
    end
    assert_response :unprocessable_entity
    assert_match "stray.png", response.body
  end

  test "flags a referenced image that was not uploaded" do
    assert_no_difference -> { Post.count } do
      post "/admin/posts/import", headers: AUTH, params: { package: md, images: [ img("cbse-affiliation-hero") ] }
    end
    assert_response :unprocessable_entity
    assert_match "references image", response.body
    assert_match "cbse-affiliation-steps-infographic.png", response.body
  end

  test "does not silently clobber an existing slug" do
    Post.create!(title: "Existing", slug: "cbse-affiliation-process")
    assert_no_difference -> { Post.count } do
      post "/admin/posts/import", headers: AUTH, params: { package: md, images: all_images }
    end
    assert_response :unprocessable_entity
    assert_match(/slug/i, response.body)
  end

  test "rejects a non-image file uploaded as an image" do
    fake = Rack::Test::UploadedFile.new(StringIO.new("not a png"), "image/png", original_filename: "cbse-affiliation-hero.png")
    assert_no_difference -> { Post.count } do
      post "/admin/posts/import", headers: AUTH, params: { package: md, images: [ fake, img("cbse-affiliation-steps-infographic"), img("cbse-affiliation-costs-infographic") ] }
    end
    assert_response :unprocessable_entity
    assert_match "not a valid PNG", response.body
  end

  test "requires the package file" do
    post "/admin/posts/import", headers: AUTH, params: { images: all_images }
    assert_response :unprocessable_entity
    assert_match "Attach the pipeline", response.body
  end
end
