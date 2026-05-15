class CheckIn < ApplicationRecord
  belongs_to :user
  belongs_to :event

  validates :user_id, uniqueness: { scope: :event_id }
  validates :checked_in_at, presence: true

  before_validation { self.checked_in_at ||= Time.current }

  after_create_commit -> { FirstStrangerDetectionJob.perform_later(id) }
end
