class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :host

  validates :checked_in_at, presence: true
  validates :user_id, uniqueness: { scope: :event_id, message: "already checked in to this event" }

  after_create :update_reputation

  private

  def update_reputation
    rep = Reputation.find_or_initialize_by(user: user, host: host)
    rep.total_count += 1
    if category.present?
      rep.by_category = rep.by_category.merge(category => rep.by_category.fetch(category, 0) + 1)
    end
    rep.save!
  end
end
