class User < ApplicationRecord
  has_secure_password validations: false

  enum :auth_method, { email: "email", google: "google", apple: "apple" }

  has_one :host_profile, dependent: :destroy
  has_many :host_totem_assignments, class_name: "HostTotemAssignment", foreign_key: :host_user_id, dependent: :destroy
  has_many :assigned_totems, through: :host_totem_assignments, source: :totem
  has_many :check_ins, dependent: :destroy
  has_many :host_subscriptions, dependent: :destroy
  has_many :totem_follows, dependent: :destroy
  has_many :notification_deliveries, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    if: :email_auth?
  validates :email, uniqueness: { case_sensitive: false, allow_nil: true }, unless: :email_auth?
  validates :google_uid, uniqueness: true, allow_nil: true
  validates :password, length: { minimum: 8 }, if: -> { email_auth? && password.present? }
  validates :auth_method, presence: true

  before_save { email&.downcase! }

  def email_auth?
    auth_method == "email"
  end

  def posthog_distinct_id
    id.to_s
  end
end
