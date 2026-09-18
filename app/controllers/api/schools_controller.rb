module Api
  class SchoolsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :set_cors_headers

    LEAN_COLS = %w[
      id name city state district board type gender grades
      annual_fees_min annual_fees_max established rating
      description image_url is_featured total_reviews student_teacher_ratio
    ].freeze

    # Boards shown as distinct pills in the sidebar.
    # Everything NOT in this list is treated as "State Board".
    CURATED_BOARDS   = [ "State Board", "ICSE", "IB", "CBSE", "IGCSE" ].freeze
    NON_STATE_BOARDS = %w[CBSE ICSE IB IGCSE Cambridge NIOS].freeze

    def index
      page     = [ params[:page].to_i, 1 ].max
      per_page = params[:per].to_i
      per_page = 24 if per_page <= 0
      per_page = [ per_page, 100 ].min

      q        = params[:q].to_s.strip
      state    = params[:state].to_s.strip
      city     = params[:city].to_s.strip
      district = params[:district].to_s.strip
      boards = Array(params[:board]).map(&:to_s).map(&:strip).reject(&:blank?)
      types  = Array(params[:type]).map(&:to_s).map(&:strip).reject(&:blank?)
      gender = params[:gender].to_s.strip
      fees_min = params[:fees_min].to_s.strip
      fees_max = params[:fees_max].to_s.strip

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

      scope = scope.where(state: state)                                    if state.present?
      scope = scope.where("district LIKE ?", "%#{district}%")            if district.present?
      # city param maps to district column — UDISE stores ward names in city, districts are real city names
      scope = scope.where("district LIKE ?", "%#{city}%")                if city.present?

      # Board filtering: "State Board" expands to every board that is NOT
      # one of the curated main boards (CBSE/ICSE/IB/IGCSE/Cambridge/NIOS).
      if boards.any?
        specific     = boards - [ "State Board" ]
        state_board  = boards.include?("State Board")

        if specific.any? && state_board
          # e.g. CBSE + State Board → board IN ('CBSE') OR board NOT IN (main list)
          scope = scope.where(
            "board IN (?) OR board NOT IN (?)", specific, NON_STATE_BOARDS
          )
        elsif specific.any?
          scope = scope.where(board: specific)
        else
          # Only "State Board" selected
          scope = scope.where.not(board: NON_STATE_BOARDS)
        end
      end

      scope = scope.where(type: types)   if types.any?
      scope = scope.where(gender: gender) if gender.present?
      scope = scope.where("annual_fees_min >= ?", fees_min.to_i) if fees_min.present?
      scope = scope.where("annual_fees_max <= ?", fees_max.to_i) if fees_max.present?

      total = scope.except(:select).count
      schools = scope
        .order(is_featured: :desc, rating: :desc, name: :asc)
        .limit(per_page)
        .offset((page - 1) * per_page)

      render json: {
        schools: schools.map { |s| school_json(s) },
        total: total,
        page: page,
        per_page: per_page,
        pages: (total.to_f / per_page).ceil
      }
    end

    def show
      school = School.find(params[:id])
      render json: { school: full_school_json(school) }
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Not found" }, status: :not_found
    end

    def cities
      q     = params[:q].to_s.strip
      limit = [ params[:limit].to_i, 200 ].min
      limit = 100 if limit == 0

      cities = if q.present?
        School.where("district LIKE ?", "#{q}%")
              .where.not(district: [ nil, "" ])
              .distinct.order(:district)
              .limit(limit)
              .pluck(:district, :state)
      else
        School.where.not(district: [ nil, "" ])
              .distinct.order(:district)
              .limit(limit)
              .pluck(:district, :state)
      end

      render json: { cities: cities.map { |c, s| { city: c, state: s } } }
    end

    def filters
      render json: {
        states:  School.distinct.order(:state).pluck(:state).compact.reject(&:blank?),
        boards:  CURATED_BOARDS,   # State Board, ICSE, IB, CBSE, IGCSE
        types:   School.distinct.order(:type).pluck(:type).compact.reject(&:blank?),
        genders: School.distinct.order(:gender).pluck(:gender).compact.reject(&:blank?)
      }
    end

    private

    def set_cors_headers
      response.headers["Access-Control-Allow-Origin"] = "*"
      response.headers["Cache-Control"] = "public, max-age=60"
    end

    def fmt_amount(n)
      return nil if n.nil? || n == 0
      if n >= 100_000 then "₹#{(n / 100_000.0).round(1)}L"
      elsif n >= 1_000 then "₹#{(n / 1_000.0).round(0).to_i}K"
      else "₹#{n}"
      end
    end

    def fmt_fees(min, max)
      return "On Request" if min.nil? && max.nil?
      if min && max
        "#{fmt_amount(min)} – #{fmt_amount(max)}"
      elsif min
        "From #{fmt_amount(min)}"
      else
        fmt_amount(max).to_s
      end
    end

    def school_json(s)
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

    def full_school_json(s)
      school_json(s).merge(
        address: s.address,
        phone: s.phone,
        email: s.email,
        website: s.website,
        affiliation_no: s.affiliation_no,
        admission_fee: s.admission_fee,
        security_deposit: s.security_deposit,
        virtual_tour_url: s.virtual_tour_url,
        pass_percentage: s.pass_percentage,
        top_scorers_pct: s.top_scorers_pct,
        admission_open: s.admission_open,
        admission_start: s.admission_start,
        admission_deadline: s.admission_deadline,
        admission_test_date: s.admission_test_date,
        admission_criteria: s.admission_criteria,
        hall_of_fame: s.hall_of_fame,
        insights: s.insights,
        gallery_images: s.gallery_images,
        video_urls: s.video_urls,
        facilities: s.facilities
      )
    end
  end
end
