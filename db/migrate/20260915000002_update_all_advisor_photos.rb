class UpdateAllAdvisorPhotos < ActiveRecord::Migration[8.1]
  PHOTOS = {
    "Alka Pandey"          => "/summit/assets/advisor_alka.png",
    "Kiran Bir Sethi"      => "/summit/assets/advisor_kiran.png",
    "Dr. Lakshmi Kumar"    => "/summit/assets/advisor_lakshmi.png",
    "Mrunal Shah"          => "/summit/assets/advisor_mrunal.png",
    "Dr. Parimal Merchant" => "/summit/assets/advisor_parimal.png",
    "Russell John Cailey"  => "/summit/assets/advisor_russell.png",
    "Dr. Sanjay Malpani"   => "/summit/assets/advisor_sanjay.png",
    "Dr. Seetha Murty"     => "/summit/assets/advisor_seetha.png",
    "Dr. Swati Popat Vats" => "/summit/assets/advisor_swati.png",
  }.freeze

  def up
    PHOTOS.each do |name, path|
      SummitSpeaker.find_by(name: name)&.update!(photo: path)
    end
  end

  def down; end
end
