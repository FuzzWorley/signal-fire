class Totem < ApplicationRecord
  has_many :host_totem_assignments
  has_many :hosts, through: :host_totem_assignments, source: :host_user
  has_many :events
  has_many :totem_follows
  has_many :empty_totem_email_captures

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers, and hyphens" }

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  def board_empty?
    return true unless active

    has_upcoming = events.active.where(recurrence_type: "weekly").exists? ||
                   events.active.where(recurrence_type: "one_time").where("start_time > ?", Time.current).exists?

    has_recent = events.active.where("end_time > ? AND end_time < ?", 30.days.ago, Time.current).exists?

    !has_upcoming && !has_recent
  end

  def active_now_events
    now = Time.current
    window_start = now - Event::CHECKIN_WINDOW_AFTER_MINUTES.minutes
    window_end   = now + Event::CHECKIN_WINDOW_BEFORE_MINUTES.minutes

    events.active
          .includes(host_user: :host_profile)
          .where("start_time <= ? AND end_time >= ?", window_end, window_start)
          .sort_by { |e|
            if e.start_time <= now && e.end_time >= now
              [0, e.start_time.to_i]
            elsif e.start_time > now
              [1, e.start_time.to_i]
            else
              [2, -e.end_time.to_i]
            end
          }
  end

  def upcoming_events
    window_end = Time.current + Event::CHECKIN_WINDOW_BEFORE_MINUTES.minutes
    events.active.includes(host_user: :host_profile).reject(&:active_now?).select { |e| e.next_occurrence > window_end }.sort_by(&:next_occurrence)
  end

  private

  def generate_slug
    base = name.parameterize
    candidate = base
    n = 2
    while Totem.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base}-#{n}"
      n += 1
    end
    self.slug = candidate
  end
end
