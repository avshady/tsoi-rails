module Api
  class SchoolsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :set_cors_headers

    def index
      render json: SchoolSearch.new(params)
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
        states:  School.listing_states,
        boards:  SchoolSearch::CURATED_BOARDS,
        types:   School.listing_types,
        genders: School.distinct.order(:gender).pluck(:gender).compact.reject(&:blank?)
      }
    end

    private

    def set_cors_headers
      response.headers["Access-Control-Allow-Origin"] = "*"
      response.headers["Cache-Control"] = "public, max-age=60"
    end

    def school_json(s)
      SchoolSearch.card(s)
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
