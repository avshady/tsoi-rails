class Post < ApplicationRecord
  CATEGORIES = [
    "School Leadership",
    "Teaching & Learning",
    "Parents",
    "EdTech",
    "Operations",
    "Summit",
    "News"
  ].freeze

  validates :title, presence: true
  validates :slug,  presence: true, uniqueness: true

  before_validation :generate_slug

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
    body.to_s.split(/\n{2,}/).first.to_s.truncate(180)
  end

  private

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
