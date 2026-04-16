class Notification < ApplicationRecord
  belongs_to :event
  belongs_to :host

  enum :status, { scheduled: "scheduled", sending: "sending", sent: "sent", failed: "failed" }
  enum :tier, { following: "following", discover: "discover" }

  validates :title, presence: true
  validates :send_at, presence: true
  validate :max_three_per_event, on: :create

  private

  def max_three_per_event
    return unless event
    if event.notifications.count >= 3
      errors.add(:base, "events may have at most 3 notifications")
    end
  end
end
