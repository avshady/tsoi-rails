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
end
