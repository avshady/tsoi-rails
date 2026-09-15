class PortalController < ApplicationController
  layout "portal"

  before_action :require_school, only: [ :dashboard, :update ]

  def login
    redirect_to portal_dashboard_path if current_portal_school
  end

  def authenticate
    token = params[:token].to_s.strip
    school = School.find_by(portal_token: token)
    if school
      session[:portal_school_id] = school.id
      redirect_to portal_dashboard_path
    else
      flash[:alert] = "Token not recognised. Please check with TSOI and try again."
      redirect_to portal_login_path
    end
  end

  def dashboard
    @school = current_portal_school
  end

  def update
    @school = current_portal_school
    allowed = %i[
      description name phone email website address
      annual_fees_min annual_fees_max admission_fee
      established grades board gender type
      admission_open admission_start admission_deadline
      admission_criteria image_url gallery_images
      student_teacher_ratio facilities insights
    ]
    attrs = params.require(:school).permit(*allowed.map(&:to_s))

    # Sanitise gallery_images: convert newline-separated URLs to JSON array
    if attrs["gallery_images"].present?
      urls = attrs["gallery_images"].split("\n").map(&:strip).reject(&:blank?)
      attrs["gallery_images"] = urls.to_json
    end

    if @school.update(attrs)
      flash[:notice] = "Profile updated successfully."
    else
      flash[:alert] = @school.errors.full_messages.join(", ")
    end
    redirect_to portal_dashboard_path
  end

  def logout
    session.delete(:portal_school_id)
    redirect_to portal_login_path
  end

  private

  def current_portal_school
    return nil unless session[:portal_school_id]
    @_portal_school ||= School.find_by(id: session[:portal_school_id])
  end

  def require_school
    redirect_to portal_login_path unless current_portal_school
  end
end
