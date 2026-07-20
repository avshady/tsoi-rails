class AddAlkaPandeySpeaker < ActiveRecord::Migration[8.1]
  def up
    SummitSpeaker.find_or_create_by!(name: "Alka Pandey") do |s|
      s.title        = "Founding Head & Academic Advisor"
      s.organisation = "Cambridge International"
      s.photo        = "/summit/assets/advisor_alka.jpg"
      s.accent_color = "#6366f1"
      s.position     = 8
    end
  end

  def down
    SummitSpeaker.find_by(name: "Alka Pandey")&.destroy
  end
end
