class FixSanjayMalpaniNameAndOrg < ActiveRecord::Migration[8.1]
  def up
    SummitSpeaker.where(name: "Sanjay Malpani").update_all(name: "Dr. Sanjay Malpani", organisation: "Malpani Group")
  end

  def down
    SummitSpeaker.where(name: "Dr. Sanjay Malpani").update_all(name: "Sanjay Malpani", organisation: "Malpani Group of Schools")
  end
end
