class NotificationDelivery < ApplicationRecord
  belongs_to :user
  belongs_to :event

  enum :notification_type, { new_event: "new_event", reminder: "reminder" }
  enum :source_type, { host_subscription: "host_subscription", totem_follow: "totem_follow" }

  validates :notification_type, presence: true
  validates :source_type, presence: true
  validates :user_id, uniqueness: { scope: [ :event_id, :notification_type ] }
end
