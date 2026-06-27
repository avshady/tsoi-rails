class SchoolsController < ApplicationController
  TOP_CITIES = %w[Hyderabad Thane Mumbai Pune Chennai Kolkata Ahmedabad Bengaluru Visakhapatnam Nagpur Surat Jaipur Lucknow Indore Bhopal Chandigarh].freeze

  def index
    @states  = School.distinct.order(:state).pluck(:state).compact.reject(&:blank?)
    @boards  = School.distinct.order(:board).pluck(:board).compact.reject(&:blank?)
    @types   = School.distinct.order(:type).pluck(:type).compact.reject(&:blank?)
    @genders = School.distinct.order(:gender).pluck(:gender).compact.reject(&:blank?)

    # Build a single UNION-ish query to check which cities have schools
    like_conditions = TOP_CITIES.map { |c| School.sanitize_sql_like(c) }
    districts_found = School.where(
      like_conditions.map { "district LIKE ?" }.join(" OR "),
      *like_conditions.map { |c| "%#{c}%" }
    ).distinct.pluck(:district)
    matched = districts_found.map(&:downcase)
    @top_cities = TOP_CITIES.select { |c| matched.any? { |d| d.include?(c.downcase) } }.first(12)

    @initial_query  = params[:q].to_s
    @initial_state  = params[:state].to_s
    @initial_city   = params[:city].to_s
    @initial_board  = params[:board].to_s
    @initial_gender = params[:gender].to_s
  end

  def show
    @school = School.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render file: "public/404.html", status: :not_found, layout: false
  end
end
