class EmptyTotemEmailCapture < ApplicationRecord
  belongs_to :totem

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :captured_at, presence: true

  before_validation { self.captured_at ||= Time.current }
end
