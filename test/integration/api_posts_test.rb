require "test_helper"

class ApiPostsTest < ActionDispatch::IntegrationTest
  TOKEN = "test-blog-token".freeze

  setup do
    @previous_token = ENV["BLOG_API_TOKEN"]
    ENV["BLOG_API_TOKEN"] = TOKEN
    Post.delete_all
  end

  teardown do
    ENV["BLOG_API_TOKEN"] = @previous_token
  end

  def auth(token = TOKEN)
    { "Authorization" => "Bearer #{token}" }
  end

  test "rejects requests without a valid token" do
    get "/api/posts"
    assert_response :unauthorized

    get "/api/posts", headers: auth("wrong")
    assert_response :unauthorized
  end

  test "is disabled when BLOG_API_TOKEN is not set" do
    ENV["BLOG_API_TOKEN"] = nil
    get "/api/posts", headers: auth
    assert_response :service_unavailable
  end

  test "creates a published post that shows on the blog" do
    post "/api/posts", headers: auth, as: :json, params: {
      title: "Choosing the Right School", body: "First paragraph.\n\nSecond paragraph.",
      category: "parent resources", cover_image: "https://example.com/cover.jpg", published: true
    }
    assert_response :created

    json = response.parsed_body["post"]
    assert_equal "choosing-the-right-school", json["slug"]
    assert_equal "Parent Resources", json["category"]
    assert_equal "The Schools of India", json["author"]
    assert json["published"]
    assert json["published_at"].present?
    assert json["url"].end_with?("/blog/choosing-the-right-school")

    get "/blog/choosing-the-right-school"
    assert_response :success
    assert_includes response.body, "Second paragraph."
  end

  test "creates drafts by default and accepts wrapped params" do
    post "/api/posts", headers: auth, as: :json, params: { post: { title: "Draft Idea", body: "WIP" } }
    assert_response :created
    json = response.parsed_body["post"]
    assert_not json["published"]
    assert_nil json["published_at"]

    get "/blog/draft-idea"
    assert_redirected_to "/blog"
  end

  test "validates title and category" do
    post "/api/posts", headers: auth, as: :json, params: { body: "No title" }
    assert_response :unprocessable_entity

    post "/api/posts", headers: auth, as: :json, params: { title: "X", category: "Parents" }
    assert_response :unprocessable_entity
    assert_match "Category must be one of", response.parsed_body["errors"].first
  end

  test "rejects an empty create" do
    post "/api/posts", headers: auth, as: :json, params: {}
    assert_response :bad_request
  end

  test "lists, shows, updates and deletes posts" do
    Post.create!(title: "Live One", published: true, published_at: 1.day.ago)
    draft = Post.create!(title: "Draft One", published: false)

    get "/api/posts", headers: auth
    assert_response :success
    assert_equal 2, response.parsed_body["total"]

    get "/api/posts?published=false", headers: auth
    assert_equal [ "draft-one" ], response.parsed_body["posts"].map { |p| p["slug"] }

    get "/api/posts/draft-one", headers: auth
    assert_response :success
    assert_equal "Draft One", response.parsed_body["post"]["title"]

    patch "/api/posts/draft-one", headers: auth, as: :json, params: { published: true, excerpt: "Now live" }
    assert_response :success
    assert draft.reload.published?
    assert draft.published_at.present?
    assert_equal "Now live", draft.excerpt

    delete "/api/posts/draft-one", headers: auth
    assert_response :success
    assert_not Post.exists?(draft.id)

    get "/api/posts/draft-one", headers: auth
    assert_response :not_found
  end
end
