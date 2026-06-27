module ApplicationHelper
  # Returns an inline style string for nav links
  # highlight: true  → always crimson
  # path matches current → crimson
  # otherwise → inherit
  def nav_link_style(*paths, highlight: false)
    current = request.path
    active = highlight || paths.any? { |p| p && current.start_with?(p) }
    color = active ? "#821E25" : "inherit"
    "text-decoration:none; color:#{color}; transition:color 0.2s;"
  end

  def fmt_amount(n)
    return "On Request" if n.nil? || n == 0
    n = n.to_i
    if n >= 100_000
      "₹#{(n / 100_000.0).round(1)}L"
    elsif n >= 1_000
      "₹#{(n / 1_000.0).round(0).to_i}K"
    else
      "₹#{n}"
    end
  end

  def fmt_fees(min, max)
    return "On Request" if min.nil? && max.nil?
    if min && max
      "#{fmt_amount(min)} – #{fmt_amount(max)}"
    elsif min
      "From #{fmt_amount(min)}"
    else
      fmt_amount(max)
    end
  end

  def star_rating(rating)
    r = rating.to_f.round(1)
    "★ #{r}"
  end
end
