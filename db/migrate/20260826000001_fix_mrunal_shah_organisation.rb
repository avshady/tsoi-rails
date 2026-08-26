class FixMrunalShahOrganisation < ActiveRecord::Migration[8.1]
  def up
    SummitSpeaker.where(name: "Mrunal Shah").update_all(organisation: "Sunday Brick")
  end

  def down
    SummitSpeaker.where(name: "Mrunal Shah").update_all(organisation: "Social Brick")
  end
end
