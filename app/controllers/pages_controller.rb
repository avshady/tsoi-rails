class PagesController < ApplicationController
  # Major Indian cities to feature in the dropdown, in preference order.
  MAJOR_CITIES = %w[
    Mumbai Delhi Bengaluru Chennai Hyderabad Kolkata Pune Ahmedabad
    Jaipur Surat Lucknow Visakhapatnam Kanpur Nagpur Indore Bhopal
    Patna Vadodara Agra Coimbatore Kochi Chandigarh Dehradun Guwahati
    Bhubaneswar Thiruvananthapuram Amritsar Varanasi Ranchi Jamshedpur
  ].freeze

  def home
    @total_schools = School.count
    @states     = School.distinct.order(:state).pluck(:state).compact.reject(&:blank?)
    @boards     = School.distinct.order(:board).pluck(:board).compact.reject(&:blank?)
    @types      = School.distinct.order(:type).pluck(:type).compact.reject(&:blank?)
    # Pick the top 10 from the curated list that actually have schools, ordered by count.
    # Use district column for city-level aggregation (UDISE stores ward-level city names;
    # district correctly groups all wards — e.g. "Pune" district = 1,556 schools).
    counts = School.where(district: MAJOR_CITIES)
                   .group(:district)
                   .count   # returns { "Pune" => 1556, "Hyderabad" => 1892, … }
    @top_cities = MAJOR_CITIES.select { |c| counts[c].to_i > 0 }
                               .sort_by { |c| -counts.fetch(c, 0) }
                               .first(10)
  end

  def parents
    @total_schools = School.count
    @states     = School.distinct.order(:state).pluck(:state).compact.reject(&:blank?)
    counts = School.where(district: MAJOR_CITIES).group(:district).count
    @top_cities = MAJOR_CITIES.select { |c| counts[c].to_i > 0 }
                               .sort_by { |c| -counts.fetch(c, 0) }
                               .first(10)
  end

  SERVICES_DATA = {
    "land-building" => {
      tags:    ["New School", "Infrastructure"],
      bg:      "#f4f0e6", dark: false, dot: "#821E25",
      card_title: "Land & Building\nInfrastructure",
      title:   "Land & Building Infrastructure",
      tagline: "From plot to school — we guide every step of your infrastructure journey.",
      desc:    "If you own land and/or are willing to build and lease a school, partner with TSOI to bring your vision to life. We connect landowners, builders, and school operators across India with the expertise needed to create world-class educational campuses.",
      img:     "/images/land-building-hero.jpg",
      img2:    "https://images.pexels.com/photos/1396122/pexels-photo-1396122.jpeg?auto=compress&cs=tinysrgb&w=900&h=600&fit=crop",
      steps: [
        { num: "01", title: "Site Assessment", body: "We evaluate your land for school viability — access roads, catchment population, zoning, and proximity to residential zones." },
        { num: "02", title: "Architecture & Layout", body: "Partner architects design child-safe, functional campuses that meet board norms for CBSE, ICSE, IB, and state boards." },
        { num: "03", title: "Regulatory Clearances", body: "From municipal approvals to NOCs and fire certificates — we manage the paperwork so you can focus on the vision." },
        { num: "04", title: "Lease or Sale Structuring", body: "Whether you want to run the school yourself or lease to an operator, we structure the deal to protect your interests." },
      ],
      features: [
        ["Property Acquisition",  "Find the perfect property with our extensive network across India."],
        ["Location Analysis",     "Strategic assessment for optimal accessibility and growth potential."],
        ["Legal Support",         "Comprehensive legal documentation and compliance support."],
        ["Builder Network",       "Trusted construction partners with experience in school campuses."],
        ["Lease Structuring",     "Flexible arrangements for land owners and school operators."],
        ["Board Compliance",      "Ensure the build meets CBSE/ICSE/state board physical norms."],
      ],
      for_who: "Landowners, real estate developers, and entrepreneurs looking to set up or lease a school campus."
    },
    "careers" => {
      tags:    ["All Schools", "Staffing"],
      bg:      "#101010", dark: true, dot: "#f4f0e6",
      card_title: "Hiring &\nCareers",
      title:   "Hiring & Careers in Education",
      tagline: "The right people make the difference. We help you find them.",
      desc:    "Connect with top-tier educational professionals. TSOI streamlines hiring for teachers, administrators, and school leadership — from bulk teacher recruitment to C-suite executive search for your institution.",
      img:     "https://images.pexels.com/photos/7580920/pexels-photo-7580920.jpeg?auto=compress&cs=tinysrgb&w=1600&h=1000&fit=crop",
      img2:    "https://images.pexels.com/photos/5709579/pexels-photo-5709579.jpeg?auto=compress&cs=tinysrgb&w=900&h=600&fit=crop",
      steps: [
        { num: "01", title: "Needs Analysis", body: "We audit your existing team structure, identify gaps, and define role specifications for every position." },
        { num: "02", title: "Talent Sourcing", body: "Access our curated database of verified educators, B.Ed graduates, and experienced school administrators." },
        { num: "03", title: "Screening & Shortlisting", body: "Every candidate is background-checked and assessed for subject knowledge, pedagogy fit, and culture alignment." },
        { num: "04", title: "Onboarding Support", body: "We help structure induction programmes and employment contracts to set your new hires up for success." },
      ],
      features: [
        ["Talent Acquisition",     "Access a curated pool of qualified educators and admin professionals."],
        ["Executive Search",       "Targeted recruitment for principal, dean, and leadership roles."],
        ["Staffing Consultation",  "Expert advice on structuring your team for maximum impact."],
        ["Background Verification","Thorough checks on qualifications, experience, and references."],
        ["Contract Templates",     "School-specific employment agreements prepared by HR specialists."],
        ["Bulk Hiring Drives",     "Coordinate mass recruitment for new school launches."],
      ],
      for_who: "School owners, principals, and HR heads looking to hire, scale, or restructure their teaching and administrative teams."
    },
    "curriculum" => {
      tags:    ["K-12", "Academic"],
      bg:      "#821E25", dark: true, dot: "#f4f0e6",
      card_title: "Curriculum &\nTextbooks",
      title:   "Curriculum & Textbooks Connect",
      tagline: "Aligned with NCF 2024. Built for how students learn today.",
      desc:    "Equip your classrooms with state-of-the-art educational resources, textbooks, and digital learning materials. We connect schools directly with leading publishers and content creators, ensuring curriculum coherence from nursery through Grade 12.",
      img:     "https://images.pexels.com/photos/1720186/pexels-photo-1720186.jpeg?auto=compress&cs=tinysrgb&w=1600&h=900&fit=crop",
      img2:    "https://images.pexels.com/photos/256395/pexels-photo-256395.jpeg?auto=compress&cs=tinysrgb&w=900&h=600&fit=crop",
      steps: [
        { num: "01", title: "Curriculum Audit", body: "We review your existing curriculum against NCF 2024 benchmarks and identify gaps in coverage, sequencing, and pedagogy." },
        { num: "02", title: "Content Mapping", body: "Map your learning objectives to the right publisher resources — physical books, workbooks, and digital modules." },
        { num: "03", title: "Publisher Connect", body: "Direct introductions to NCERT, Oxford, Cambridge, S. Chand, and niche curriculum specialists." },
        { num: "04", title: "Teacher Training", body: "Ensure your faculty can deliver the new curriculum with confidence through our content-specific workshops." },
      ],
      features: [
        ["NCF 2024 Alignment",  "Ensure your curriculum meets the latest national educational standards."],
        ["Publisher Network",   "Direct partnerships with leading publishers for competitive pricing."],
        ["Digital Integration", "Seamless blend of physical textbooks and e-learning modules."],
        ["Lesson Planning",     "Ready-to-use annual planners and unit plans for each subject."],
        ["Assessment Design",   "Formative and summative assessments mapped to learning outcomes."],
        ["Co-Curricular",       "Arts, sports, and life-skills programmes to round the curriculum."],
      ],
      for_who: "Academic coordinators, curriculum heads, and school owners upgrading or aligning to the National Curriculum Framework 2024."
    },
    "erp-lms" => {
      tags:    ["All Schools", "Technology"],
      bg:      "#ece7da", dark: false, dot: "#821E25",
      card_title: "ERP & LMS\nSolutions",
      title:   "ERP & LMS Solutions",
      tagline: "Modern schools run on smart systems. We implement them for you.",
      desc:    "Implement cutting-edge Enterprise Resource Planning and Learning Management Systems tailored for Indian schools. From fee collection and attendance to parent communication and online learning — we digitise your entire school operation.",
      img:     "https://images.pexels.com/photos/265087/pexels-photo-265087.jpeg?auto=compress&cs=tinysrgb&w=1600&h=900&fit=crop",
      img2:    "https://images.pexels.com/photos/3861958/pexels-photo-3861958.jpeg?auto=compress&cs=tinysrgb&w=900&h=600&fit=crop",
      steps: [
        { num: "01", title: "Requirements Scoping", body: "We map your school's workflows — admissions, fees, attendance, exams, HR — and recommend the right ERP platform." },
        { num: "02", title: "System Selection", body: "Evaluate and shortlist from Fedena, Classter, SchoolMint, Brightspace, or custom builds based on your scale and budget." },
        { num: "03", title: "Implementation", body: "Full deployment including data migration, user role setup, integrations with payment gateways and communication tools." },
        { num: "04", title: "Training & Handover", body: "Staff onboarding workshops, admin manuals, and a dedicated helpline for the first three months post-launch." },
      ],
      features: [
        ["System Integration",  "Deploy ERP for attendance, fees, and grading seamlessly."],
        ["LMS Deployment",      "Interactive platforms for learning, assignments, and parent comms."],
        ["Technical Support",   "Ongoing training and support for your staff and educators."],
        ["Data Migration",      "Safe transfer of all historical student and financial records."],
        ["Payment Gateway",     "Integrated online fee collection with automated reminders."],
        ["Analytics Dashboard", "Real-time insights on student performance, attendance, and revenue."],
      ],
      for_who: "School administrators and IT heads looking to digitise operations, improve parent experience, and gain data-driven insights."
    },
    "school-management" => {
      tags:    ["1–10 Yrs", "Consulting"],
      bg:      "#1A1A18", dark: true, dot: "#f4f0e6",
      card_title: "School Management\nAdvisory",
      title:   "School Management Advisory",
      tagline: "Expert eyes on your school. Actionable plans for every department.",
      desc:    "Partner with TSOI for comprehensive management support, enhancing both academic outcomes and operational efficiency. Whether you are a single-campus school hitting a growth ceiling or a chain looking to standardise — our consultants have seen it all.",
      img:     "https://images.pexels.com/photos/9623645/pexels-photo-9623645.jpeg?auto=compress&cs=tinysrgb&w=1600&h=1000&fit=crop",
      img2:    "https://images.pexels.com/photos/7580944/pexels-photo-7580944.jpeg?auto=compress&cs=tinysrgb&w=900&h=600&fit=crop",
      steps: [
        { num: "01", title: "Diagnostic Audit", body: "A 360° review covering academics, HR, finance, marketing, admissions, compliance, and parent satisfaction." },
        { num: "02", title: "Prioritised Roadmap", body: "A clear, time-bound action plan ranking initiatives by impact and ease of implementation — not a 100-page report." },
        { num: "03", title: "Implementation Support", body: "Our consultants work alongside your team, not just hand over a deck. Monthly check-ins hold everyone accountable." },
        { num: "04", title: "Performance Review", body: "Quarterly KPI reviews against agreed metrics — admissions growth, fee collection rate, staff retention, board results." },
      ],
      features: [
        ["Operational Audit",     "In-depth analysis of school operations and areas for improvement."],
        ["Leadership Coaching",   "Mentoring for school principals and administrative leaders."],
        ["Financial Strategy",    "Budget optimisation and financial planning for sustainable growth."],
        ["Admissions Marketing",  "Build a pipeline of quality applicants through digital and community channels."],
        ["Compliance Review",     "Ensure all board, government, and tax compliance is current."],
        ["Parent Engagement",     "Systems to improve NPS, reduce churn, and build community loyalty."],
      ],
      for_who: "School owners and principals of established schools (1–10 years) who want to optimise performance before scaling."
    },
    "pre-schools" => {
      tags:    ["Pre-K", "Founders"],
      bg:      "#f8f4ec", dark: false, dot: "#821E25",
      card_title: "Preschool\nSetup",
      title:   "Preschool Setup",
      tagline: "Where little learners begin. We build the foundations right.",
      desc:    "Launch a state-of-the-art preschool with TSOI's end-to-end guidance, from curriculum design to interior setup. India's preschool sector is one of the fastest-growing in education — and getting the early years right sets the tone for everything that follows.",
      img:     "https://images.pexels.com/photos/8363051/pexels-photo-8363051.jpeg?auto=compress&cs=tinysrgb&w=1600&h=900&fit=crop",
      img2:    "https://images.pexels.com/photos/3661541/pexels-photo-3661541.jpeg?auto=compress&cs=tinysrgb&w=900&h=600&fit=crop",
      steps: [
        { num: "01", title: "Concept & Positioning", body: "Define your preschool's philosophy — Montessori, play-based, Reggio Emilia, or blended — and the age groups you'll serve." },
        { num: "02", title: "Space Design", body: "Child-safe, joyful interiors with age-appropriate furniture, learning corners, outdoor play, and sensory areas." },
        { num: "03", title: "Curriculum & Kits", body: "A structured early years programme aligned with NEP 2020's Foundational Stage, complete with activity kits and assessments." },
        { num: "04", title: "Staff Training & Launch", body: "Train your team in early childhood pedagogy, child safety protocols, and parent communication — then open with confidence." },
      ],
      features: [
        ["Space Design",           "Child-friendly architectural planning and interior design."],
        ["Early Years Curriculum", "Developmentally appropriate learning frameworks for young minds."],
        ["Staff Training",         "Specialised training for early childhood educators and caretakers."],
        ["Safety Compliance",      "Fire, hygiene, and child safety norms met before day one."],
        ["Parent Programmes",      "Parent orientation, communication templates, and progress formats."],
        ["Franchise Options",      "Scale your preschool into a chain with TSOI's franchise playbook."],
      ],
      for_who: "Entrepreneurs and educators launching their first preschool, or K-12 schools adding an early years wing."
    },
  }.freeze

  def about; end

  def services
    img_overrides = SiteContent.get_json("service_images") rescue {}
    @services = SERVICES_DATA.map do |slug, data|
      img     = img_overrides.dig(slug, "img")  || data[:img]
      img2    = img_overrides.dig(slug, "img2") || data[:img2]
      data.merge(slug: slug, img: img, img2: img2, href: service_detail_path(slug))
    end
  end

  def service_detail
    base = SERVICES_DATA[params[:slug]]
    return render :service_not_found, status: 404 unless base
    img_ov  = (SiteContent.get_json("service_images") rescue {})[params[:slug]] || {}
    text_ov = (SiteContent.get_json("service_texts")  rescue {})[params[:slug]] || {}
    @service = base.merge(
      img:     img_ov["img"].presence     || base[:img],
      img2:    img_ov["img2"].presence    || base[:img2],
      title:   text_ov["title"].presence   || base[:title],
      tagline: text_ov["tagline"].presence || base[:tagline],
      desc:    text_ov["desc"].presence    || base[:desc]
    )
  end
  def partner; end
  def terms; end
  def privacy; end
  def recognition; end

  def contact; end

  def contact_send
    flash[:notice] = "Thank you! We'll get back to you shortly."
    redirect_to contact_path
  end

  def service_inquiry
    inquiry = Inquiry.new(
      name:        params[:name].to_s.strip,
      email:       params[:email].to_s.strip,
      phone:       params[:phone].to_s.strip,
      school_name: params[:school_name].to_s.strip,
      service:     params[:service].to_s.strip,
      message:     params[:message].to_s.strip,
      status:      "new"
    )
    if inquiry.save
      flash[:notice] = "Thanks #{inquiry.name.split.first}! Our team will be in touch within 24 hours."
    else
      flash[:alert] = inquiry.errors.full_messages.join(", ")
    end
    redirect_to "#{service_detail_path(params[:slug])}#inquiry-form"
  end

  def summit
    render layout: false
  end

  def summit_notify
    email        = params[:email].to_s.strip
    name         = params[:name].to_s.strip
    role         = params[:role].to_s.strip
    organisation = params[:organisation].to_s.strip
    pass_id      = params[:passId].to_s.strip

    newsletter = role == "Newsletter Subscriber"

    parts = []
    parts << "Role: #{role}"         if role.present? && !newsletter
    parts << "Pass: #{pass_id}"      if pass_id.present?

    Inquiry.create!(
      name:        name,
      email:       email,
      school_name: organisation.presence,
      service:     newsletter ? "Summit Newsletter" : "Summit Registration",
      message:     parts.join(" · ").presence,
      status:      "new"
    )

    first_name = name.split.first.presence || "You"
    flash[:notice] = newsletter ? "Subscribed! We'll keep you updated." : "Welcome, #{first_name}! You're on our priority list."
    redirect_to summit_path
  rescue => e
    flash[:notice] = "You're on our priority list — we'll be in touch soon."
    redirect_to summit_path
  end
end
