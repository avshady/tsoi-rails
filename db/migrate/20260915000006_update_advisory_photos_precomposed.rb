class UpdateAdvisoryPhotosPrecomposed < ActiveRecord::Migration[8.1]
  PHOTOS = {
    "Alka Pandey"          => "/summit/assets/advisory_alka.png",
    "Lakshmi Kumar"        => "/summit/assets/advisory_lakshmi.png",
    "Parimal Merchant"     => "/summit/assets/advisory_parimal.png",
    "Dr. Sanjay Malpani"   => "/summit/assets/advisory_sanjay.png",
    "Dr. Swati Popat Vats" => "/summit/assets/advisory_swati.png",
    "Russell John Cailey"  => "/summit/assets/advisory_russell.png",
    "Mrunal Shah"          => "/summit/assets/advisory_mrunal.png",
    "Seetha Murty"         => "/summit/assets/advisory_seetha.png",
    "Dr. Seetha Murty"     => "/summit/assets/advisory_seetha.png",
    "Kiran Bir Sethi"      => "/summit/assets/advisory_kiran.png",
  }.freeze

  def up
    PHOTOS.each do |name, path|
      SummitSpeaker.find_by(name: name)&.update!(photo: path)
    end
  end

  def down; end
end
