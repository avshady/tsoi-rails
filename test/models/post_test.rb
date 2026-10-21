require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "json_ld accepts raw JSON as-is" do
    p = Post.new(title: "T", json_ld: '{"@type":"Article"}')
    assert p.valid?
    assert_equal '{"@type":"Article"}', p.json_ld
  end

  test "json_ld strips a single script wrapper" do
    p = Post.new(title: "T", json_ld: %(<script type="application/ld+json">\n{"@type":"FAQPage"}\n</script>))
    assert p.valid?
    assert_equal({ "@type" => "FAQPage" }, JSON.parse(p.json_ld))
  end

  test "json_ld combines several script blocks into one array" do
    p = Post.new(title: "T", json_ld: <<~HTML)
      <script type="application/ld+json">{"@type":"Article"}</script>
      <script type="application/ld+json">{"@type":"FAQPage"}</script>
    HTML
    assert p.valid?
    assert_equal %w[Article FAQPage], JSON.parse(p.json_ld).map { |d| d["@type"] }
  end

  test "blank json_ld is stored as nil" do
    p = Post.new(title: "T", json_ld: "  ")
    assert p.valid?
    assert_nil p.json_ld
  end

  test "summary skips headings and images" do
    p = Post.new(body: "## Heading\n\n![x](/a.png)\n\nThe **first** paragraph.")
    assert_equal "The first paragraph.", p.summary
  end
  test "publishing immediately stamps publish_at and published_at to now" do
    freeze = Time.utc(2026, 10, 21, 12, 0, 0)
    travel_to(freeze) do
      post = Post.create!(title: "Now", published: true)
      assert_equal freeze, post.publish_at
      assert_equal freeze, post.published_at
      assert post.live?
      assert_not post.scheduled?
    end
  end

  test "a future publish_at with published true is scheduled, not live" do
    post = Post.create!(title: "Later", published: true, publish_at: 2.days.from_now)
    assert post.scheduled?
    assert_not post.live?
    assert_equal post.publish_at, post.published_at
  end

  test "drafts are never live or scheduled even with a publish_at" do
    post = Post.create!(title: "Draft", published: false, publish_at: 2.days.from_now)
    assert_not post.live?
    assert_not post.scheduled?
    assert_nil post.published_at
  end

  test "live scope returns only due published posts" do
    Post.delete_all
    Post.create!(title: "Live", published: true)
    Post.create!(title: "Due", published: true, publish_at: 1.hour.ago)
    Post.create!(title: "Future", published: true, publish_at: 1.hour.from_now)
    Post.create!(title: "Draft2", published: false)
    legacy = Post.create!(title: "Legacy")
    legacy.update_columns(published: true, publish_at: nil, published_at: 1.year.ago)

    slugs = Post.live.map(&:slug)
    assert_includes slugs, "live"
    assert_includes slugs, "due"
    assert_includes slugs, "legacy"
    assert_not_includes slugs, "future"
    assert_not_includes slugs, "draft2"
  end
end
