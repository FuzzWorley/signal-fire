class UserHostFirstSeen < ApplicationRecord
  belongs_to :user
  belongs_to :host_user, class_name: "User", foreign_key: :host_user_id

  validates :first_seen_at, presence: true
  validates :user_id, uniqueness: { scope: :host_user_id }
end
