module Admin
  class DashboardController < BaseController
    layout "admin"

    def index
      @total_schools  = School.count
      @featured_count = School.where(is_featured: 1).count
      @recent_schools = School.order(created_at: :desc).limit(10)
      @states_count   = School.distinct.count(:state)
    end
  end
end
