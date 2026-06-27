class SchoolsController < ApplicationController
  def index
    # The full finder page — JS handles the search/filter via API
    @states = School.distinct.order(:state).pluck(:state).compact.reject(&:blank?)
    @boards = School.distinct.order(:board).pluck(:board).compact.reject(&:blank?)
    @types  = School.distinct.order(:type).pluck(:type).compact.reject(&:blank?)

    # Pre-select from query params (for direct URL sharing)
    @initial_query  = params[:q].to_s
    @initial_state  = params[:state].to_s
    @initial_city   = params[:city].to_s
    @initial_board  = params[:board].to_s
  end

  def show
    @school = School.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render file: "public/404.html", status: :not_found, layout: false
  end
end
