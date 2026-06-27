module Admin
  class ContentController < BaseController
    layout "admin"

    def index
      @services = PagesController::SERVICES_DATA
      @img_overrides = SiteContent.get_json("service_images") rescue {}
      @inquiries_count = Inquiry.count
      @new_inquiries   = Inquiry.where(status: "new").count
    end

    def update_service_image
      slug     = params[:slug]
      field    = params[:field].to_s  # "img" or "img2"
      url      = params[:url].to_s.strip
      return redirect_to(admin_content_path, alert: "Invalid field.") unless %w[img img2].include?(field)

      overrides         = SiteContent.get_json("service_images")
      overrides[slug]   ||= {}
      overrides[slug][field] = url
      SiteContent.set_json("service_images", overrides)

      flash[:notice] = "Image updated for #{PagesController::SERVICES_DATA[slug]&.dig(:title) || slug}."
      redirect_to admin_content_path
    end

    def update_service_text
      slug   = params[:slug]
      texts  = SiteContent.get_json("service_texts")
      texts[slug] ||= {}
      %w[title tagline desc].each do |f|
        texts[slug][f] = params[f].to_s.strip if params[f].present?
      end
      SiteContent.set_json("service_texts", texts)
      flash[:notice] = "Text updated."
      redirect_to admin_content_path
    end
  end
end
