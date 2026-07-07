class UpdateParimalMerchantDetails < ActiveRecord::Migration[8.1]
  def up
    SummitSpeaker.where(name: "Piramal").update_all(
      name: "Parimal Merchant",
      title: "Director – Global Family Managed Business Program"
    )
  end

  def down
    SummitSpeaker.where(name: "Parimal Merchant").update_all(
      name: "Piramal",
      title: "Speaker"
    )
  end
end
