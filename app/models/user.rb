class User < ApplicationRecord
  has_secure_password validations: false

  enum :auth_method, { email: "email", google: "google", apple: "apple" }

  has_one :host_profile
  has_many :hosted_totem_assignments, class_name: "HostTotemAssignment", foreign_key: :host_user_id
  has_many :assigned_totems, through: :hosted_totem_assignments, source: :totem
  has_many :check_ins
  has_many :host_subscriptions
  has_many :totem_follows

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
end
