module PostsHelper
  BODY_TAGS = %w[
    h2 h3 h4 h5 h6 p br hr strong b em i a ul ol li blockquote code pre
    table thead tbody tr th td img figure figcaption div
  ].freeze
  BODY_ATTRIBUTES = %w[href title target rel src alt id class colspan rowspan].freeze

  KRAMDOWN_OPTIONS = {
    input: "GFM",
    hard_wrap: true,
    auto_ids: true,
    # Keep straight quotes, "--" and "..." exactly as typed.
    smart_quotes: %w[apos apos quot quot],
    typographic_symbols: { hellip: "...", mdash: "---", ndash: "--", laquo: "<<", raquo: ">>", laquo_space: "<< ", raquo_space: " >>" }
  }.freeze

  # Renders a post body (Markdown) to sanitized HTML.
  #
  # GFM with hard_wrap keeps older plain-text posts rendering as before:
  # blank lines make paragraphs and single line breaks become <br>, matching
  # the simple_format output they were written for.
  def post_body_html(post)
    html = Kramdown::Document.new(post.body.to_s, **KRAMDOWN_OPTIONS).to_html

    doc = Nokogiri::HTML5.fragment(html)
    doc.css("a[href]").each do |a|
      next unless external_link?(a["href"])
      a["target"] = "_blank"
      a["rel"] = "noopener noreferrer"
    end
    doc.css("img").each { |img| img["loading"] = "lazy" }
    # Let wide tables scroll sideways on phones instead of overflowing the page.
    doc.css("table").each { |t| t.wrap('<div class="table-wrap"></div>') }

    sanitize doc.to_html, tags: BODY_TAGS, attributes: BODY_ATTRIBUTES + %w[loading]
  end

  # JSON-LD for the <head>. It is emitted unescaped so it stays valid JSON;
  # "</" is written as "<\/" (an equivalent JSON escape) so the content can
  # never close the surrounding <script> tag early.
  def post_json_ld_tag(post)
    return if post.json_ld.blank?
    tag.script(post.json_ld.gsub("</") { "<\\/" }.html_safe, type: "application/ld+json")
  end

  private

  def external_link?(href)
    uri = URI.parse(href)
    uri.host.present? && !uri.host.end_with?(URI.parse(Post::SITE_URL).host)
  rescue URI::InvalidURIError
    false
  end
end
