require "test_helper"

class BlogPostPageTest < ActionDispatch::IntegrationTest
  setup { Post.delete_all }

  test "an existing plain-text post still renders as paragraphs" do
    Post.create!(title: "Old Post", published: true, published_at: 1.day.ago,
                 body: "First paragraph line one.\nLine two.\n\nSecond \"quoted\" paragraph -- here...")
    get "/blog/old-post"
    assert_response :success
    assert_includes response.body, "<p>First paragraph line one.<br>\nLine two.</p>"
    assert_includes response.body, "<p>Second \"quoted\" paragraph -- here...</p>"
  end

  test "a markdown post renders headings, links, bold, tables and images safely" do
    Post.create!(title: "Markdown Post", published: true, published_at: 1.day.ago, body: <<~MD)
      Intro with **bold** text.

      ## Quick answer

      | Question | Answer |
      |---|---|
      | Fees? | Varies |

      Read the [CBSE circular](https://cbse.gov.in/x) or our [school list](/schools).

      - one
      - two

      ![Fee guide infographic](/images/blog/fee-guide-infographic.png)

      <script>alert("x")</script>
    MD
    get "/blog/markdown-post"
    assert_response :success
    body = response.body
    assert_includes body, '<h2 id="quick-answer">Quick answer</h2>'
    assert_includes body, "<strong>bold</strong>"
    assert_includes body, "<table>"
    assert_includes body, "<th>Question</th>"
    assert_includes body, '<a href="https://cbse.gov.in/x" target="_blank" rel="noopener noreferrer">CBSE circular</a>'
    assert_includes body, '<a href="/schools">school list</a>'
    assert_includes body, "<li>one</li>"
    assert_includes body, '<img src="/images/blog/fee-guide-infographic.png" alt="Fee guide infographic" loading="lazy">'
    assert_not_includes body, 'alert("x")</script>'
  end

  test "the head has title, description, canonical, open graph and json-ld" do
    # "</script>" inside a JSON string must not end the script tag early.
    json_ld = '[{"@context":"https://schema.org","@type":"Article","headline":"A </script> test"},' \
              '{"@context":"https://schema.org","@type":"FAQPage"}]'
    Post.create!(title: "SEO Post", published: true, published_at: 1.day.ago, body: "Hello",
                 meta_title: "SEO Post Meta Title", meta_description: "A meta description.",
                 cover_image: "/images/blog/seo-hero.jpg", cover_image_alt: "Hero alt", json_ld: json_ld)
    get "/blog/seo-post"
    doc = Nokogiri::HTML5(response.body)

    assert_equal "SEO Post Meta Title", doc.at("title").text
    assert_equal "A meta description.", doc.at('meta[name="description"]')["content"]
    assert_equal "https://theschoolsofindia.org/blog/seo-post", doc.at('link[rel="canonical"]')["href"]
    assert_equal "article", doc.at('meta[property="og:type"]')["content"]
    assert_equal "SEO Post Meta Title", doc.at('meta[property="og:title"]')["content"]
    assert_equal "https://theschoolsofindia.org/images/blog/seo-hero.jpg", doc.at('meta[property="og:image"]')["content"]
    assert_equal "Hero alt", doc.at('img[src="/images/blog/seo-hero.jpg"]')["alt"]

    scripts = doc.css('script[type="application/ld+json"]')
    assert_equal 1, scripts.size
    data = JSON.parse(scripts.first.text)
    assert_equal %w[Article FAQPage], data.map { |d| d["@type"] }
    assert_equal "A </script> test", data.first["headline"]
  end

  test "falls back to the post title and summary without meta fields" do
    Post.create!(title: "Plain", published: true, published_at: 1.day.ago, body: "## Heading\n\nFirst real paragraph.")
    get "/blog/plain"
    doc = Nokogiri::HTML5(response.body)
    assert_equal "Plain — The Schools of India", doc.at("title").text
    assert_equal "First real paragraph.", doc.at('meta[name="description"]')["content"]
    assert_nil doc.at('script[type="application/ld+json"]')
  end

  test "drafts are not public" do
    Post.create!(title: "Secret Draft", body: "x")
    get "/blog/secret-draft"
    assert_redirected_to "/blog"
  end
end
