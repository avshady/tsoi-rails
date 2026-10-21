class Post < ApplicationRecord
  CATEGORIES = [
    "School Launch",
    "School Operations",
    "Curriculum & Academics",
    "EdTech & Innovation",
    "School Leadership",
    "Education Policy",
    "School Growth & Scaling",
    "School Selection",
    "Parent Resources"
  ].freeze

  # Public origin used for canonical and Open Graph URLs.
  SITE_URL = "https://theschoolsofindia.org".freeze

  validates :title, presence: true
  validates :slug,  presence: true, uniqueness: true
  # Only checked when the category changes, so older posts keep their legacy category.
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true, if: :category_changed?
  validate  :json_ld_must_be_valid_json

  before_validation :generate_slug
  before_validation :normalize_json_ld

  scope :published, -> { where(published: true).order(Arel.sql("COALESCE(published_at, created_at) DESC")) }
  scope :recent,    -> { order(Arel.sql("COALESCE(published_at, created_at) DESC")) }

  # Use the slug in URLs instead of the id.
  def to_param
    slug
  end

  def display_date
    (published_at || created_at)&.strftime("%-d %B %Y")
  end

  # Rough reading time from the body's word count.
  def reading_minutes
    words = body.to_s.split.size
    [ (words / 200.0).ceil, 1 ].max
  end

  def summary
    return excerpt if excerpt.present?

    # Body is Markdown: use the text of the first real paragraph, skipping
    # headings, images and tables.
    html = Kramdown::Document.new(body.to_s, input: "GFM", hard_wrap: false).to_html
    first = Nokogiri::HTML5.fragment(html).css("p").map { |p| p.text.squish }.find(&:present?)
    first.to_s.truncate(180)
  end

  def seo_title
    meta_title.presence || "#{title} — The Schools of India"
  end

  def seo_description
    meta_description.presence || summary
  end

  def canonical_url
    "#{SITE_URL}/blog/#{slug}"
  end

  # Cover image as an absolute URL, for Open Graph.
  def cover_image_url
    return if cover_image.blank?
    cover_image.start_with?("/") ? "#{SITE_URL}#{cover_image}" : cover_image
  end

  private

  # The pipeline delivers JSON-LD wrapped in one or more
  # <script type="application/ld+json"> tags. Store only the JSON; several
  # blocks are combined into one JSON array, which search engines accept.
  def normalize_json_ld
    raw = json_ld.to_s.strip
    if raw.blank?
      self.json_ld = nil
      return
    end
    return unless raw.match?(/<script/i)

    blocks = raw.scan(%r{<script[^>]*>(.*?)</script>}im).flatten.map(&:strip).reject(&:blank?)
    parsed = blocks.map { |b| JSON.parse(b) }
    self.json_ld = JSON.pretty_generate(parsed.one? ? parsed.first : parsed)
  rescue JSON::ParserError
    # Leave as-is; json_ld_must_be_valid_json reports the error.
  end

  def json_ld_must_be_valid_json
    return if json_ld.blank?
    JSON.parse(json_ld)
  rescue JSON::ParserError => e
    errors.add(:json_ld, "is not valid JSON (#{e.message.lines.first.to_s.strip.truncate(120)})")
  end

  def generate_slug
    return if slug.present? || title.blank?

    base = title.parameterize
    candidate = base
    n = 2
    while Post.where(slug: candidate).where.not(id: id).exists?
      candidate = "#{base}-#{n}"
      n += 1
    end
    self.slug = candidate
  end
end
