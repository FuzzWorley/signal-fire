class NotificationDelivery < ApplicationRecord
  belongs_to :user
  belongs_to :event

  enum :notification_type, {
    new_event:      "new_event",
    reminder:       "reminder",
    cancelled:      "cancelled",
    first_stranger: "first_stranger",
    weekly_digest:  "weekly_digest"
  }
  enum :source_type, {
    host_follow:    "host_follow",
    totem_favorite: "totem_favorite",
    direct:         "direct"
  }

  validates :notification_type, presence: true
  validates :source_type, presence: true
  validates :user_id, uniqueness: { scope: [ :event_id, :notification_type ] }
end
