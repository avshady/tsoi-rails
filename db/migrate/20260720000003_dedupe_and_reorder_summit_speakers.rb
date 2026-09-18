class DedupeAndReorderSummitSpeakers < ActiveRecord::Migration[8.1]
  # Canonical advisor board. `match` is a LIKE fragment used to catch
  # name variants (e.g. "Dr Swati" vs "Dr. Swati"); the first/cleanest
  # record is kept, any duplicates are removed, and the keeper is
  # normalized to the canonical values + position.
  CANON = [
    { match: "Laxmi Kumar",         name: "Laxmi Kumar",          title: "Director",                                   organisation: "Avasara Academy",                     accent: "#ff2a7f", position: 1 },
    { match: "Sanjay Malpani",      name: "Sanjay Malpani",       title: "Director",                                   organisation: "Malpani Group of Schools",            accent: "#7c3aed", position: 2 },
    { match: "Parimal Merchant",    name: "Parimal Merchant",     title: "Director – Global Family Managed Business",  organisation: "SP Jain School of Global Management", accent: "#2de67b", position: 3 },
    { match: "Swati Popat Vats",    name: "Dr. Swati Popat Vats", title: "President",                                  organisation: "ECA & Podar Education Network",       accent: "#0891b2", position: 4, photo: "/summit/assets/advisor_swati.jpg" },
    { match: "Russell John Cailey", name: "Russell John Cailey",  title: "CEO & Founder",                              organisation: "Almach AI™",                          accent: "#d97706", position: 5 },
    { match: "Seetha Murty",        name: "Seetha Murty",                                                                                                                    position: 6 },
    { match: "Mrunal Shah",         name: "Mrunal Shah",          title: "Founder & Play Expert",                      organisation: "Social Brick",                        accent: "#f59e0b", position: 7 },
    { match: "Alka Pandey",         name: "Alka Pandey",          title: "Founding Head & Academic Advisor",           organisation: "Cambridge International",              accent: "#6366f1", position: 8 }
  ].freeze

  def up
    CANON.each do |c|
      recs = SummitSpeaker.where("name LIKE ?", "%#{c[:match]}%").order(:id).to_a
      next if recs.empty?

      keeper = recs.find { |r| r.name == c[:name] } || recs.first
      (recs - [ keeper ]).each(&:destroy)

      attrs = { name: c[:name], position: c[:position] }
      attrs[:title]        = c[:title]        if c[:title]
      attrs[:organisation] = c[:organisation] if c[:organisation]
      attrs[:accent_color] = c[:accent]       if c[:accent]
      attrs[:photo]        = c[:photo]        if c[:photo]
      keeper.update!(attrs)
    end
  end

  def down
    # Data cleanup — not reversible.
  end
end
