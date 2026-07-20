class AddRemainingSummitSpeakers < ActiveRecord::Migration[8.1]
  def up
    # Correct Parimal Merchant's affiliation (was Piramal Foundation)
    SummitSpeaker.where(name: "Parimal Merchant").update_all(
      title:        "Director – Global Family Managed Business",
      organisation: "SP Jain School of Global Management"
    )

    SummitSpeaker.find_or_create_by!(name: "Dr. Swati Popat Vats") do |s|
      s.title        = "President"
      s.organisation = "ECA & Podar Education Network"
      s.photo        = "/summit/assets/advisor_swati.jpg"
      s.accent_color = "#0891b2"
      s.position     = 4
    end

    SummitSpeaker.find_or_create_by!(name: "Russell John Cailey") do |s|
      s.title        = "CEO & Founder"
      s.organisation = "Almach AI™"
      s.photo        = "/summit/assets/advisor_russell.jpg"
      s.accent_color = "#d97706"
      s.position     = 5
    end

    SummitSpeaker.find_or_create_by!(name: "Mrunal Shah") do |s|
      s.title        = "Founder & Play Expert"
      s.organisation = "Social Brick"
      s.photo        = "/summit/assets/advisor_mrunal.jpg"
      s.accent_color = "#f59e0b"
      s.position     = 7
    end
  end

  def down
    SummitSpeaker.where(name: ["Dr. Swati Popat Vats", "Russell John Cailey", "Mrunal Shah"]).destroy_all
    SummitSpeaker.where(name: "Parimal Merchant").update_all(
      title:        "Director – Global Family Managed Business Program",
      organisation: "Piramal Foundation"
    )
  end
end
