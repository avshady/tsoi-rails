# A city or region parents can browse by, used to turn a visitor's coordinates
# into "schools near you". Each place maps to the exact district values the
# listings use for it (district data is uneven: Mumbai alone is spread over
# "Mumbai", "Mumbai Ii", "Mumbai (Suburban)" and "Navi Mumbai"), or to a whole
# state for small states and Delhi, whose districts are stored ward by ward.
class SchoolPlace
  # Visitors further than this from every place get their state instead.
  NEAR_KM = 60

  Place = Struct.new(:name, :state, :lat, :lon, :districts) do
    def whole_state? = districts.nil?
    def value        = "place:#{name}"

    def apply(scope)
      scope = scope.where(state: state)
      whole_state? ? scope : scope.where(district: districts)
    end
  end

  # name, state, lat, lon, districts (defaults to [name]; :state = the whole state)
  ROWS = [
    [ "Mumbai", "Maharashtra", 19.076, 72.878, [ "Mumbai", "Mumbai Ii", "Mumbai (Suburban)", "Navi Mumbai" ] ],
    [ "Thane", "Maharashtra", 19.218, 72.978 ],
    [ "Palghar", "Maharashtra", 19.697, 72.765 ],
    [ "Pune", "Maharashtra", 18.520, 73.857 ],
    [ "Nagpur", "Maharashtra", 21.146, 79.088 ],
    [ "Nashik", "Maharashtra", 19.998, 73.790 ],
    [ "Chhatrapati Sambhajinagar", "Maharashtra", 19.876, 75.343, [ "Chhatrapati Sambhajinagar", "Aurangabad" ] ],
    [ "Solapur", "Maharashtra", 17.660, 75.906 ],
    [ "Kolhapur", "Maharashtra", 16.705, 74.243 ],
    [ "Sangli", "Maharashtra", 16.852, 74.581 ],
    [ "Satara", "Maharashtra", 17.680, 74.018 ],
    [ "Jalgaon", "Maharashtra", 21.004, 75.563 ],
    [ "Dhule", "Maharashtra", 20.902, 74.775 ],
    [ "Nanded", "Maharashtra", 19.138, 77.321 ],
    [ "Latur", "Maharashtra", 18.408, 76.560 ],
    [ "Parbhani", "Maharashtra", 19.268, 76.770 ],
    [ "Jalna", "Maharashtra", 19.841, 75.886 ],
    [ "Yavatmal", "Maharashtra", 20.389, 78.120 ],
    [ "Raigad", "Maharashtra", 18.641, 72.872, [ "Raigarh (Maharashtra)", "Raigad" ] ],
    [ "Hyderabad", "Telangana", 17.385, 78.487, [ "Hyderabad", "Medchal Malkajgiri", "Ranga Reddy" ] ],
    [ "Sangareddy", "Telangana", 17.619, 78.082 ],
    [ "Warangal", "Telangana", 17.990, 79.575, [ "Hanumakonda", "Warangal" ] ],
    [ "Karimnagar", "Telangana", 18.439, 79.129 ],
    [ "Nizamabad", "Telangana", 18.672, 78.094 ],
    [ "Nalgonda", "Telangana", 17.057, 79.267 ],
    [ "Khammam", "Telangana", 17.247, 80.151 ],
    [ "Mahabubnagar", "Telangana", 16.737, 77.998 ],
    [ "Visakhapatnam", "Andhra Pradesh", 17.687, 83.218 ],
    [ "Vijayawada", "Andhra Pradesh", 16.506, 80.648, [ "Ntr", "Vijayawada", "Krishna" ] ],
    [ "Guntur", "Andhra Pradesh", 16.307, 80.436 ],
    [ "Nellore", "Andhra Pradesh", 14.443, 79.987 ],
    [ "Tirupati", "Andhra Pradesh", 13.629, 79.419 ],
    [ "Kurnool", "Andhra Pradesh", 15.828, 78.037 ],
    [ "Kadapa", "Andhra Pradesh", 14.467, 78.824 ],
    [ "Anantapur", "Andhra Pradesh", 14.682, 77.601 ],
    [ "Kakinada", "Andhra Pradesh", 16.989, 82.247 ],
    [ "Rajahmundry", "Andhra Pradesh", 17.000, 81.804, [ "East Godavari" ] ],
    [ "Srikakulam", "Andhra Pradesh", 18.297, 83.897 ],
    [ "Bengaluru", "Karnataka", 12.972, 77.595, [ "Bengaluru", "Bengaluru U South", "Bengaluru U North", "Bangalore Urban", "Bangalore Rural" ] ],
    [ "Mysuru", "Karnataka", 12.296, 76.639 ],
    [ "Mangaluru", "Karnataka", 12.914, 74.856, [ "Dakshina Kannada" ] ],
    [ "Udupi", "Karnataka", 13.341, 74.747 ],
    [ "Hubballi-Dharwad", "Karnataka", 15.364, 75.124, [ "Dharwad" ] ],
    [ "Belagavi", "Karnataka", 15.850, 74.498 ],
    [ "Kalaburagi", "Karnataka", 17.329, 76.834 ],
    [ "Vijayapura", "Karnataka", 16.830, 75.710 ],
    [ "Ballari", "Karnataka", 15.139, 76.921 ],
    [ "Davanagere", "Karnataka", 14.464, 75.921 ],
    [ "Shivamogga", "Karnataka", 13.929, 75.568 ],
    [ "Tumakuru", "Karnataka", 13.340, 77.101 ],
    [ "Chennai", "Tamil Nadu", 13.083, 80.271, [ "Chennai", "Chennai (Ext. Gcc)", "Chengalpattu", "Tiruvallur" ] ],
    [ "Coimbatore", "Tamil Nadu", 11.017, 76.956 ],
    [ "Madurai", "Tamil Nadu", 9.925, 78.120 ],
    [ "Tiruchirappalli", "Tamil Nadu", 10.791, 78.705 ],
    [ "Salem", "Tamil Nadu", 11.664, 78.146 ],
    [ "Tiruppur", "Tamil Nadu", 11.108, 77.341 ],
    [ "Erode", "Tamil Nadu", 11.341, 77.717 ],
    [ "Vellore", "Tamil Nadu", 12.917, 79.133 ],
    [ "Tirunelveli", "Tamil Nadu", 8.714, 77.757 ],
    [ "Thoothukkudi", "Tamil Nadu", 8.764, 78.135 ],
    [ "Nagercoil", "Tamil Nadu", 8.178, 77.411, [ "Kanniyakumari" ] ],
    [ "Thanjavur", "Tamil Nadu", 10.787, 79.138 ],
    [ "Dindigul", "Tamil Nadu", 10.362, 77.980 ],
    [ "Cuddalore", "Tamil Nadu", 11.748, 79.768 ],
    [ "Puducherry", "Puducherry", 11.934, 79.830, [ "Puducherry", "Pondicherry", "Oulgaret", "Mudhaliarpet", "Thattanchavadi" ] ],
    [ "Kochi", "Kerala", 9.982, 76.300, [ "Ernakulam", "Kochi" ] ],
    [ "Thiruvananthapuram", "Kerala", 8.524, 76.937 ],
    [ "Kozhikode", "Kerala", 11.259, 75.780 ],
    [ "Thrissur", "Kerala", 10.527, 76.214 ],
    [ "Kollam", "Kerala", 8.893, 76.614 ],
    [ "Kottayam", "Kerala", 9.592, 76.522 ],
    [ "Kannur", "Kerala", 11.874, 75.370 ],
    [ "Malappuram", "Kerala", 11.073, 76.074 ],
    [ "Palakkad", "Kerala", 10.787, 76.654 ],
    [ "Alappuzha", "Kerala", 9.498, 76.339 ],
    [ "Delhi", "Delhi", 28.614, 77.209, :state ],
    [ "Gurugram", "Haryana", 28.459, 77.027 ],
    [ "Faridabad", "Haryana", 28.408, 77.318 ],
    [ "Sonipat", "Haryana", 28.993, 77.016 ],
    [ "Panipat", "Haryana", 29.391, 76.969 ],
    [ "Karnal", "Haryana", 29.686, 76.990 ],
    [ "Ambala", "Haryana", 30.378, 76.777 ],
    [ "Rohtak", "Haryana", 28.895, 76.607 ],
    [ "Hisar", "Haryana", 29.149, 75.722 ],
    [ "Noida", "Uttar Pradesh", 28.575, 77.355, [ "Gautam Buddha Nagar", "Noida" ] ],
    [ "Ghaziabad", "Uttar Pradesh", 28.669, 77.454 ],
    [ "Lucknow", "Uttar Pradesh", 26.847, 80.947 ],
    [ "Kanpur", "Uttar Pradesh", 26.449, 80.331, [ "Kanpur Nagar", "Kanpur", "Kanpur Dehat" ] ],
    [ "Agra", "Uttar Pradesh", 27.177, 78.008 ],
    [ "Varanasi", "Uttar Pradesh", 25.318, 82.974 ],
    [ "Prayagraj", "Uttar Pradesh", 25.436, 81.846 ],
    [ "Meerut", "Uttar Pradesh", 28.984, 77.706 ],
    [ "Gorakhpur", "Uttar Pradesh", 26.760, 83.373 ],
    [ "Bareilly", "Uttar Pradesh", 28.367, 79.432 ],
    [ "Moradabad", "Uttar Pradesh", 28.839, 78.773 ],
    [ "Aligarh", "Uttar Pradesh", 27.884, 78.080 ],
    [ "Mathura", "Uttar Pradesh", 27.492, 77.674 ],
    [ "Saharanpur", "Uttar Pradesh", 29.968, 77.546 ],
    [ "Muzaffarnagar", "Uttar Pradesh", 29.473, 77.704 ],
    [ "Jhansi", "Uttar Pradesh", 25.448, 78.569 ],
    [ "Dehradun", "Uttarakhand", 30.316, 78.032 ],
    [ "Haridwar", "Uttarakhand", 29.946, 78.164 ],
    [ "Haldwani", "Uttarakhand", 29.219, 79.513, [ "Nainital" ] ],
    [ "Rudrapur", "Uttarakhand", 28.975, 79.400, [ "Udham Singh Nagar" ] ],
    [ "Chandigarh", "Chandigarh", 30.733, 76.779, :state ],
    [ "Mohali", "Punjab", 30.704, 76.717, [ "Sas Nagar", "Mohali" ] ],
    [ "Ludhiana", "Punjab", 30.901, 75.857 ],
    [ "Amritsar", "Punjab", 31.634, 74.872 ],
    [ "Jalandhar", "Punjab", 31.326, 75.576 ],
    [ "Patiala", "Punjab", 30.340, 76.386 ],
    [ "Bathinda", "Punjab", 30.211, 74.945 ],
    [ "Shimla", "Himachal Pradesh", 31.105, 77.173 ],
    [ "Jammu", "Jammu & Kashmir", 32.727, 74.857 ],
    [ "Srinagar", "Jammu & Kashmir", 34.084, 74.797 ],
    [ "Leh", "Ladakh", 34.153, 77.577 ],
    [ "Jaipur", "Rajasthan", 26.912, 75.787 ],
    [ "Jodhpur", "Rajasthan", 26.238, 73.024 ],
    [ "Udaipur", "Rajasthan", 24.585, 73.712 ],
    [ "Kota", "Rajasthan", 25.213, 75.865 ],
    [ "Ajmer", "Rajasthan", 26.450, 74.640 ],
    [ "Bikaner", "Rajasthan", 28.022, 73.312 ],
    [ "Sri Ganganagar", "Rajasthan", 29.904, 73.877, [ "Sri Ganganagar", "Sriganganagar", "Ganganagar" ] ],
    [ "Ahmedabad", "Gujarat", 23.023, 72.571 ],
    [ "Gandhinagar", "Gujarat", 23.216, 72.637 ],
    [ "Surat", "Gujarat", 21.170, 72.831 ],
    [ "Vadodara", "Gujarat", 22.307, 73.181 ],
    [ "Rajkot", "Gujarat", 22.303, 70.802 ],
    [ "Bhavnagar", "Gujarat", 21.765, 72.151 ],
    [ "Jamnagar", "Gujarat", 22.470, 70.058 ],
    [ "Anand", "Gujarat", 22.556, 72.951 ],
    [ "Bhuj", "Gujarat", 23.242, 69.667, [ "Kachchh" ] ],
    [ "Silvassa & Daman", "Dadra & Nagar Haveli and Daman & Diu", 20.274, 73.008, :state ],
    [ "Goa", "Goa", 15.400, 73.950, :state ],
    [ "Indore", "Madhya Pradesh", 22.720, 75.858 ],
    [ "Bhopal", "Madhya Pradesh", 23.260, 77.413 ],
    [ "Jabalpur", "Madhya Pradesh", 23.181, 79.987 ],
    [ "Gwalior", "Madhya Pradesh", 26.218, 78.183 ],
    [ "Ujjain", "Madhya Pradesh", 23.180, 75.785 ],
    [ "Raipur", "Chhattisgarh", 21.251, 81.630 ],
    [ "Durg-Bhilai", "Chhattisgarh", 21.190, 81.284, [ "Durg" ] ],
    [ "Bilaspur", "Chhattisgarh", 22.079, 82.139 ],
    [ "Kolkata", "West Bengal", 22.573, 88.364 ],
    [ "Howrah", "West Bengal", 22.596, 88.264 ],
    [ "North 24 Parganas", "West Bengal", 22.722, 88.481, [ "North Twenty Four Parganas" ] ],
    [ "Hooghly", "West Bengal", 22.906, 88.396 ],
    [ "Asansol-Durgapur", "West Bengal", 23.620, 87.150, [ "Paschim Bardhaman", "Durgapur" ] ],
    [ "Siliguri", "West Bengal", 26.727, 88.395, [ "Darjeeling" ] ],
    [ "Patna", "Bihar", 25.594, 85.138 ],
    [ "Gaya", "Bihar", 24.796, 85.008 ],
    [ "Muzaffarpur", "Bihar", 26.120, 85.365 ],
    [ "Bhagalpur", "Bihar", 25.244, 86.972 ],
    [ "Darbhanga", "Bihar", 26.152, 85.897 ],
    [ "Ranchi", "Jharkhand", 23.344, 85.310 ],
    [ "Jamshedpur", "Jharkhand", 22.805, 86.203, [ "East Singhbhum" ] ],
    [ "Dhanbad", "Jharkhand", 23.796, 86.430 ],
    [ "Bokaro", "Jharkhand", 23.669, 86.151 ],
    [ "Bhubaneswar", "Odisha", 20.296, 85.825, [ "Khordha" ] ],
    [ "Cuttack", "Odisha", 20.462, 85.883 ],
    [ "Berhampur", "Odisha", 19.315, 84.792, [ "Ganjam" ] ],
    [ "Rourkela", "Odisha", 22.260, 84.854, [ "Sundargarh" ] ],
    [ "Sambalpur", "Odisha", 21.467, 83.973 ],
    [ "Balasore", "Odisha", 21.494, 86.933 ],
    [ "Guwahati", "Assam", 26.144, 91.736, [ "Kamrup-Metro", "Kamrup" ] ],
    [ "Dibrugarh", "Assam", 27.472, 94.912 ],
    [ "Silchar", "Assam", 24.833, 92.779, [ "Cachar" ] ],
    [ "Shillong", "Meghalaya", 25.578, 91.893, [ "East Khasi Hills" ] ],
    [ "Agartala", "Tripura", 23.831, 91.287, [ "West Tripura" ] ],
    [ "Imphal", "Manipur", 24.817, 93.937, [ "Imphal-West" ] ],
    [ "Aizawl", "Mizoram", 23.727, 92.718 ],
    [ "Nagaland", "Nagaland", 25.800, 93.900, :state ],
    [ "Itanagar", "Arunachal Pradesh", 27.084, 93.605, [ "Papumpara" ] ],
    [ "Sikkim", "Sikkim", 27.330, 88.612, :state ],
    [ "Port Blair", "Andaman & Nicobar Islands", 11.623, 92.726, [ "South Andaman" ] ]
  ].freeze

  ALL = ROWS.map do |name, state, lat, lon, districts|
    districts = [ name ] if districts.nil?
    Place.new(name, state, lat, lon, districts == :state ? nil : districts.freeze).freeze
  end.freeze

  BY_NAME = ALL.index_by(&:name).freeze

  def self.find(name) = BY_NAME[name.to_s]

  # The place a visitor at (lat, lon) is in, or nil when they are not near any
  # (the caller then falls back to the nearest place's state).
  def self.nearest(lat, lon)
    ALL.min_by { |p| distance_km(lat, lon, p.lat, p.lon) }
  end

  def self.near?(place, lat, lon) = distance_km(lat, lon, place.lat, place.lon) <= NEAR_KM

  def self.distance_km(lat1, lon1, lat2, lon2)
    rad = Math::PI / 180
    dlat = (lat2 - lat1) * rad
    dlon = (lon2 - lon1) * rad
    a = Math.sin(dlat / 2)**2 + Math.cos(lat1 * rad) * Math.cos(lat2 * rad) * Math.sin(dlon / 2)**2
    6371 * 2 * Math.asin(Math.sqrt(a))
  end
end
