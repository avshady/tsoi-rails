class UpdateSanjayMalpaniDesignation < ActiveRecord::Migration[8.1]
  def up
    SummitSpeaker.find_by(name: "Dr. Sanjay Malpani")&.update!(
      title: "Chairman",
      organisation: "Dhruv Global School"
    )
  end

  def down; end
end
