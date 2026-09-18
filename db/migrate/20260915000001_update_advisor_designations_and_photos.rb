class UpdateAdvisorDesignationsAndPhotos < ActiveRecord::Migration[8.1]
  UPDATES = [
    { name: "Alka Pandey",          title: "Academic Advisor - South Asia",                                         organisation: "Cambridge International",                          photo: "/summit/assets/advisor_alka.png" },
    { name: "Dr. Parimal Merchant", title: "Director - Global Family Managed Business",                              organisation: "SP Jain School of Global Management" },
    { name: "Dr. Lakshmi Kumar",    title: "Director",                                                               organisation: "Avasara Academy" },
    { name: "Dr. Sanjay Malpani",   title: "Director - Malpani Group; Chairman - Dhruv Global School",              organisation: "Malpani Group" },
    { name: "Dr. Seetha Murty",     title: "President - Association for Heads of IB World Schools (India & South Asia)", organisation: "Association for Heads of IB World Schools" },
    { name: "Dr. Swati Popat Vats", title: "President - ECA & Podar Education Network",                             organisation: "Podar Education Network" },
    { name: "Mrunal Shah",          title: "Founder & Play Expert",                                                  organisation: "Sunday Bricks" },
    { name: "Russell John Cailey",  title: "CEO & Founder",                                                          organisation: "Almach AI™" },
    { name: "Kiran Bir Sethi",      photo: "/summit/assets/advisor_kiran.png" },
  ].freeze

  def up
    UPDATES.each do |attrs|
      sp = SummitSpeaker.find_by(name: attrs[:name])
      next unless sp
      sp.update!(attrs.except(:name))
    end
  end

  def down
    # intentionally irreversible — restoring old values would require prior state
  end
end
