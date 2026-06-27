module Admin
  class SchoolsController < BaseController
    layout "admin"

    def index
      @q      = params[:q].to_s
      @state  = params[:state].to_s
      @page   = [params[:page].to_i, 1].max
      per     = 50

      scope = School.all
      scope = scope.where("name LIKE ? OR city LIKE ?", "%#{@q}%", "%#{@q}%") if @q.present?
      scope = scope.where(state: @state) if @state.present?

      @total   = scope.count
      @schools = scope.order(:name).limit(per).offset((@page - 1) * per)
      @states  = School.distinct.order(:state).pluck(:state).compact
    end

    def show
      @school = School.find(params[:id])
    end

    def edit
      @school = School.find(params[:id])
    end

    def update
      @school = School.find(params[:id])
      if @school.update(school_params)
        redirect_to admin_school_path(@school), notice: "School updated."
      else
        render :edit
      end
    end

    def generate_token
      @school = School.find(params[:id])
      token = SecureRandom.hex(16).scan(/.{4}/).join("-").upcase
      @school.update!(portal_token: token)
      flash[:notice] = "Portal token generated for #{@school.name}."
      redirect_to edit_admin_school_path(@school)
    end

    private

    def school_params
      params.require(:school).permit(
        :name, :city, :state, :district, :board, :type, :gender, :grades,
        :annual_fees_min, :annual_fees_max, :established, :rating, :description,
        :image_url, :is_featured, :phone, :email, :website, :address,
        :student_teacher_ratio, :admission_fee, :security_deposit,
        :virtual_tour_url, :pass_percentage, :top_scorers_pct,
        :admission_open, :admission_start, :admission_deadline,
        :admission_test_date, :admission_criteria, :hall_of_fame,
        :insights, :facilities, :gallery_images, :video_urls
      )
    end
  end
end
