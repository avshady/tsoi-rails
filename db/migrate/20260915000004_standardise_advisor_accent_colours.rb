class StandardiseAdvisorAccentColours < ActiveRecord::Migration[8.1]
  PALETTE = %w[#FF2A7F #7C3AED #2DE67B #06B6D4].freeze

  def up
    SummitSpeaker.order(:position).each_with_index do |sp, i|
      sp.update!(accent_color: PALETTE[i % 4])
    end
  end

  def down; end
end
