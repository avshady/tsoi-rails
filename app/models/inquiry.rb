class Inquiry < ApplicationRecord
  validates :name, :email, :service, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
