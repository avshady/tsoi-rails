class SummitSpeaker < ApplicationRecord
  validates :name, presence: true
  default_scope { order(:position, :created_at) }
end
