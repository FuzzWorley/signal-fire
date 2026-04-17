class HostSubscription < ApplicationRecord
  belongs_to :user
  belongs_to :host_user, class_name: "User", foreign_key: :host_user_id

  validates :user_id, uniqueness: { scope: :host_user_id }
end
