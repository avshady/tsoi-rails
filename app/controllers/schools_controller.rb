class SchoolsController < ApplicationController
  TOP_CITIES = %w[Mumbai Delhi Bengaluru Chennai Hyderabad Kolkata Pune Ahmedabad Jaipur Lucknow Surat Visakhapatnam Chandigarh Indore Bhopal].freeze

  def index
    @states  = School.distinct.order(:state).pluck(:state).compact.reject(&:blank?)
    @boards  = School.distinct.order(:board).pluck(:board).compact.reject(&:blank?)
    @types   = School.distinct.order(:type).pluck(:type).compact.reject(&:blank?)
    @genders = School.distinct.order(:gender).pluck(:gender).compact.reject(&:blank?)

    counts = School.where(district: TOP_CITIES).group(:district).count
    @top_cities = TOP_CITIES.select { |c| counts[c].to_i > 0 }.first(12)

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
