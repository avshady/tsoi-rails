class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :fmt_fees_range

  def fmt_fees_range(min, max)
    return "On Request" if min.nil? && max.nil?
    fmt = ->(n) {
      if n >= 100_000 then "₹#{(n / 100_000.0).round(1)}L"
      elsif n >= 1_000 then "₹#{(n / 1_000.0).round(0).to_i}K"
      else "₹#{n}"
      end
    }
    if min && max
      "#{fmt.call(min)} – #{fmt.call(max)}"
    elsif min
      "From #{fmt.call(min)}"
    else
      fmt.call(max)
    end
  end
end
