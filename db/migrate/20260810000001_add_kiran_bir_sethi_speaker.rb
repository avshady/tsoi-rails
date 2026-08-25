class AddKiranBirSethiSpeaker < ActiveRecord::Migration[8.1]
  def up
    SummitSpeaker.find_or_create_by!(name: "Kiran Bir Sethi") do |s|
      s.title        = "Founder"
      s.organisation = "Riverside School & Design for Change"
      s.photo        = "/summit/assets/advisor_kiran.jpg"
      s.accent_color = "#e11d48"
      s.position     = 9
    end
  end

  def down
    SummitSpeaker.find_by(name: "Kiran Bir Sethi")&.destroy
  end
end
