class User < ApplicationRecord
  has_one :host
  has_many :push_tokens, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :attended_events, through: :attendances, source: :event
  has_many :reputations, dependent: :destroy

  enum :role, { attendee: "attendee", admin: "admin" }
  enum :host_status, { none: "none", pending: "pending", approved: "approved", rejected: "rejected" }

  validates :phone_number, uniqueness: true, allow_nil: true,
    format: { with: /\A\+[1-9]\d{1,14}\z/, message: "must be E.164 format (e.g. +15551234567)" }
  validates :email, uniqueness: true, allow_nil: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :google_uid, uniqueness: true, allow_nil: true
  validates :radius_km, numericality: { greater_than: 0 }
  validate :requires_at_least_one_identity

  def following_notifications_enabled?
    notification_prefs.fetch("following", true)
  end

  def discover_notifications_enabled?
    notification_prefs.fetch("discover", true)
  end

  private

  def requires_at_least_one_identity
    if phone_number.blank? && google_uid.blank?
      errors.add(:base, "must have a phone number or Google account")
    end
  end
end
