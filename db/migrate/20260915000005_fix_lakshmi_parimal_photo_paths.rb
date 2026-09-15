class FixLakshmiParimalPhotoPaths < ActiveRecord::Migration[8.1]
  def up
    SummitSpeaker.find_by(name: "Lakshmi Kumar")&.update!(photo: "/summit/assets/advisor_lakshmi.png")
    SummitSpeaker.find_by(name: "Parimal Merchant")&.update!(photo: "/summit/assets/advisor_parimal.png")
  end

  def down; end
end
