module Admin
  class InquiriesController < BaseController
    layout "admin"

    def index
      @inquiries = Inquiry.order(created_at: :desc)
      # Mark all as read when viewed
      Inquiry.where(status: "new").update_all(status: "seen")
    end

    def destroy
      Inquiry.find(params[:id]).destroy
      flash[:notice] = "Inquiry deleted."
      redirect_to admin_inquiries_path
    end
  end
end
