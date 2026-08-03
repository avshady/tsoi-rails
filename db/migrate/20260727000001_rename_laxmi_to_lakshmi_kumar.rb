class RenameLaxmiToLakshmiKumar < ActiveRecord::Migration[8.1]
  def up
    SummitSpeaker.where("name LIKE ?", "%axmi Kumar%").update_all(name: "Lakshmi Kumar")
  end

  def down
    SummitSpeaker.where(name: "Lakshmi Kumar").update_all(name: "Laxmi Kumar")
  end
end
