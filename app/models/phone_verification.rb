class PhoneVerification < ApplicationRecord
  CODE_LENGTH = 6
  EXPIRY_MINUTES = 10

  validates :phone_number, presence: true
  validates :code, presence: true
  validates :expires_at, presence: true

  scope :active, -> { where("expires_at > ?", Time.current).where(verified_at: nil) }

  def self.generate_for(phone_number)
    where(phone_number: phone_number).delete_all
    create!(
      phone_number: phone_number,
      code: SecureRandom.random_number(10**CODE_LENGTH).to_s.rjust(CODE_LENGTH, "0"),
      expires_at: EXPIRY_MINUTES.minutes.from_now
    )
  end

  def self.verify(phone_number, code)
    active.find_by(phone_number: phone_number, code: code)&.tap do |v|
      v.update!(verified_at: Time.current)
    end
  end
end
