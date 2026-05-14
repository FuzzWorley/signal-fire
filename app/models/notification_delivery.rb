class NotificationDelivery < ApplicationRecord
  belongs_to :user
  belongs_to :event

  enum :notification_type, { new_event: "new_event", reminder: "reminder", cancelled: "cancelled" }
  enum :source_type, { host_follow: "host_follow", totem_favorite: "totem_favorite" }

  validates :notification_type, presence: true
  validates :source_type, presence: true
  validates :user_id, uniqueness: { scope: [ :event_id, :notification_type ] }
end
