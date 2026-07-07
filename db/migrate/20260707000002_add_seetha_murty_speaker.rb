class AddSeethaMurtySpeaker < ActiveRecord::Migration[8.0]
  def up
    SummitSpeaker.find_or_create_by!(name: 'Seetha Murty') do |s|
      s.title        = 'President'
      s.organisation = 'Heads Association of IB World Schools, India'
      s.photo        = '/summit/assets/advisor_seetha.jpg'
      s.accent_color = '#0d9488'
      s.position     = 6
    end
  end

  def down
    SummitSpeaker.find_by(name: 'Seetha Murty')&.destroy
  end
end
