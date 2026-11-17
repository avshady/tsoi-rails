# The school listing query behind /api/schools and the first page of results
# that /parents renders into the page.
class SchoolSearch
  LEAN_COLS = %w[
    id name city state district board type gender grades
    annual_fees_min annual_fees_max established rating
    description image_url is_featured total_reviews student_teacher_ratio
  ].freeze

  # Boards shown as distinct pills in the sidebar.
  # Everything NOT in this list is treated as "State Board".
  CURATED_BOARDS   = [ "State Board", "ICSE", "IB", "CBSE", "IGCSE", "Preschool" ].freeze
  NON_STATE_BOARDS = %w[CBSE ICSE IB IGCSE Cambridge NIOS Preschool].freeze

  attr_reader :page, :per_page, :location

  def initialize(params)
    @params   = params
    @page     = [ params[:page].to_i, 1 ].max
    @per_page = params[:per].to_i
    @per_page = 24 if @per_page <= 0
    @per_page = [ @per_page, 100 ].min
    @location = resolve_location
  end

  def total
    @total ||= scope.except(:select).count
  end

  def pages = (total.to_f / per_page).ceil

  def schools
    scope.order(is_featured: :desc, rating: :desc, name: :asc).limit(per_page).offset((page - 1) * per_page)
  end

  def as_json(*)
    {
      schools: schools.map { |s| self.class.card(s) },
      total: total,
      page: page,
      per_page: per_page,
      pages: pages,
      location: location
    }.compact
  end

  def self.card(s)
    {
      id: s.id,
      name: s.name,
      city: s.city,
      state: s.state,
      district: s.district,
      board: s.board,
      type: s.type,
      gender: s.gender,
      grades: s.grades,
      annual_fees_min: s.annual_fees_min,
      annual_fees_max: s.annual_fees_max,
      fees_display: fmt_fees(s.annual_fees_min, s.annual_fees_max),
      established: s.established,
      rating: s.rating,
      total_reviews: s.total_reviews,
      description: s.description,
      image_url: s.image_url,
      is_featured: s.is_featured,
      student_teacher_ratio: s.student_teacher_ratio
    }
  end

  def self.fmt_amount(n)
    return nil if n.nil? || n == 0
    if n >= 100_000 then "₹#{(n / 100_000.0).round(1)}L"
    elsif n >= 1_000 then "₹#{(n / 1_000.0).round(0).to_i}K"
    else "₹#{n}"
    end
  end

  def self.fmt_fees(min, max)
    return "On Request" if min.nil? && max.nil?
    if min && max
      "#{fmt_amount(min)} – #{fmt_amount(max)}"
    elsif min
      "From #{fmt_amount(min)}"
    else
      fmt_amount(max).to_s
    end
  end

  # True when `board` is one of the comma-separated entries in the board column.
  def self.board_listed_sql(board)
    like = School.sanitize_sql_like(board)
    School.sanitize_sql_array([
      "(board = ? OR board LIKE ? OR board LIKE ? OR board LIKE ?)",
      board, "#{like}, %", "%, #{like}", "%, #{like}, %"
    ])
  end

  private

  # lat/lon (from the visitor's browser) pick the nearest place, or their state
  # when no listed place is close. Returned to the page so it can show and
  # remember the choice.
  def resolve_location
    lat = Float(@params[:lat], exception: false)
    lon = Float(@params[:lon], exception: false)
    return unless lat && lon && lat.between?(-90, 90) && lon.between?(-180, 180)

    place = SchoolPlace.nearest(lat, lon)
    if SchoolPlace.near?(place, lat, lon)
      { value: place.value, label: place.name }
    elsif SchoolPlace.distance_km(lat, lon, place.lat, place.lon) <= 300
      { value: "state:#{place.state}", label: place.state }
    end
  end

  def scope
    @scope ||= build_scope
  end

  def build_scope
    q        = @params[:q].to_s.strip
    state    = @params[:state].to_s.strip
    city     = @params[:city].to_s.strip
    district = @params[:district].to_s.strip
    place    = SchoolPlace.find(@params[:place].to_s.strip)
    boards   = Array(@params[:board]).map(&:to_s).map(&:strip).reject(&:blank?)
    types    = Array(@params[:type]).map(&:to_s).map(&:strip).reject(&:blank?)
    gender   = @params[:gender].to_s.strip
    fees_min = @params[:fees_min].to_s.strip
    fees_max = @params[:fees_max].to_s.strip

    if location
      kind, value = location[:value].split(":", 2)
      kind == "place" ? place = SchoolPlace.find(value) : state = value
    end

    scope = School.select(LEAN_COLS.join(", "))

    # Full-text search or LIKE fallback
    if q.present?
      begin
        terms = q.split.map { |w| "+#{w}*" }.join(" ")
        scope = scope.where(
          "MATCH(name, city, description) AGAINST(? IN BOOLEAN MODE)", terms
        )
      rescue
        scope = scope.where("name LIKE ? OR city LIKE ?", "%#{q}%", "%#{q}%")
      end
    end

    scope = place.apply(scope)                                         if place
    scope = scope.where(state: state)                                  if state.present?
    scope = scope.where("district LIKE ?", "%#{district}%")            if district.present?
    # city param maps to district column — UDISE stores ward names in city, districts are real city names
    scope = scope.where("district LIKE ?", "%#{city}%")                if city.present?

    # Board filtering. A school can hold several boards ("CBSE, IGCSE"), so a
    # board matches any entry in that list. "State Board" means none of the
    # main boards (CBSE/ICSE/IB/IGCSE/Cambridge/NIOS/Preschool) is listed.
    if boards.any?
      clauses = (boards - [ "State Board" ]).map { |b| self.class.board_listed_sql(b) }
      if boards.include?("State Board")
        clauses << "NOT (#{NON_STATE_BOARDS.map { |b| self.class.board_listed_sql(b) }.join(' OR ')})"
      end
      scope = scope.where(clauses.map { |c| "(#{c})" }.join(" OR "))
    end

    scope = scope.where(type: types)   if types.any?
    scope = scope.where(gender: gender) if gender.present?
    scope = scope.where("annual_fees_min >= ?", fees_min.to_i) if fees_min.present?
    scope = scope.where("annual_fees_max <= ?", fees_max.to_i) if fees_max.present?
    scope
  end
end
