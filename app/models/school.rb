class School < ApplicationRecord
  self.table_name = "schools"
  # Disable Rails STI — our 'type' column is school type (Private/Government), not inheritance
  self.inheritance_column = :_type_disabled

  # Scopes
  scope :featured, -> { where(is_featured: 1) }
  scope :by_state,  ->(s) { where(state: s) if s.present? }
  scope :by_board,  ->(b) { where(board: b) if b.present? }
  scope :by_type,   ->(t) { where(type: t) if t.present? }
  scope :by_gender, ->(g) { where(gender: g) if g.present? }
  scope :by_city,   ->(c) { where(city: c) if c.present? }
  scope :by_fees,   ->(min, max) {
    q = all
    q = q.where("annual_fees_min >= ?", min.to_i) if min.present?
    q = q.where("annual_fees_max <= ?", max.to_i) if max.present?
    q
  }

  # Listing-wide figures that every Parents Corner visit needs. They scan the
  # whole table, so they are cached briefly rather than run per request.
  LISTING_CACHE_TTL = 10.minutes

  def self.listing_total
    Rails.cache.fetch("schools/listing_total", expires_in: LISTING_CACHE_TTL) { count }
  end

  def self.listing_states
    Rails.cache.fetch("schools/listing_states", expires_in: LISTING_CACHE_TTL) do
      distinct.order(:state).pluck(:state).compact.reject(&:blank?)
    end
  end

  def self.listing_types
    Rails.cache.fetch("schools/listing_types", expires_in: LISTING_CACHE_TTL) do
      distinct.order(:type).pluck(:type).compact.reject(&:blank?)
    end
  end

  # School counts for the given places, by place name.
  def self.place_counts(places)
    Rails.cache.fetch([ "schools/place_counts", *places.map(&:name) ], expires_in: LISTING_CACHE_TTL) do
      places.to_h { |p| [ p.name, p.apply(all).count ] }
    end
  end

  # Parse JSON-like fields stored as comma-separated strings
  def facilities_list
    return [] if facilities.blank?
    facilities.split(",").map(&:strip).reject(&:blank?)
  end

  def gallery_images_list
    return [] if gallery_images.blank?
    begin
      JSON.parse(gallery_images)
    rescue
      gallery_images.split(",").map(&:strip).reject(&:blank?)
    end
  end

  def video_urls_list
    return [] if video_urls.blank?
    begin
      JSON.parse(video_urls)
    rescue
      video_urls.split(",").map(&:strip).reject(&:blank?)
    end
  end

  def hall_of_fame_list
    return [] if hall_of_fame.blank?
    begin
      JSON.parse(hall_of_fame)
    rescue
      hall_of_fame.split(",").map(&:strip).reject(&:blank?)
    end
  end

  def admission_criteria_list
    return [] if admission_criteria.blank?
    admission_criteria.split(/[\n,]+/).map(&:strip).reject(&:blank?)
  end

  def board_list
    return [ "CBSE" ] if board.blank?
    board.split(/[,\/]/).map(&:strip).reject(&:blank?)
  end

  def fmt_fees
    if annual_fees_min && annual_fees_max
      "#{fmt_amount(annual_fees_min)} – #{fmt_amount(annual_fees_max)}"
    elsif annual_fees_min
      "From #{fmt_amount(annual_fees_min)}"
    else
      "On Request"
    end
  end

  def fmt_monthly
    return nil unless annual_fees_min
    monthly = annual_fees_min / 12
    fmt_amount(monthly)
  end

  private

  def fmt_amount(n)
    return "On Request" if n.nil? || n == 0
    if n >= 100_000
      "₹#{(n / 100_000.0).round(1)}L"
    elsif n >= 1_000
      "₹#{(n / 1_000.0).round(0).to_i}K"
    else
      "₹#{n}"
    end
  end
end
