class Event < ApplicationRecord
  CHECKIN_WINDOW_BEFORE_MINUTES = 30
  CHECKIN_WINDOW_AFTER_MINUTES = 30

  belongs_to :totem
  belongs_to :host_user, class_name: "User"
  has_many :check_ins
  has_one :anonymous_check_in_count
  has_many :notification_deliveries

  enum :recurrence_type, { one_time: "one_time", weekly: "weekly" }
  enum :chat_platform, {
    whatsapp: "whatsapp",
    discord: "discord",
    telegram: "telegram",
    signal: "signal",
    groupme: "groupme",
    slack: "slack"
  }
  enum :status, { active: "active", cancelled: "cancelled" }

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :recurrence_type, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :chat_url, presence: true
  validates :chat_platform, presence: true
  validates :status, presence: true
  validate :end_time_after_start_time

  before_validation :generate_slug, if: -> { slug.blank? && title.present? }

  def active_now?
    window_start = start_time - CHECKIN_WINDOW_BEFORE_MINUTES.minutes
    window_end = end_time + CHECKIN_WINDOW_AFTER_MINUTES.minutes
    Time.current.between?(window_start, window_end)
  end

  def window_state
    return :cancelled if cancelled?

    now = Time.current
    window_before_start = start_time - CHECKIN_WINDOW_BEFORE_MINUTES.minutes
    window_after_end    = end_time   + CHECKIN_WINDOW_AFTER_MINUTES.minutes

    if now < window_before_start   then :before
    elsif now < start_time         then :starting_soon
    elsif now <= end_time          then :happening_now
    elsif now <= window_after_end  then :just_ended
    else                                :past
    end
  end

  def next_occurrence
    return start_time unless weekly?

    now = Time.current
    return start_time if start_time > now

    weeks_ahead = ((now - start_time) / 1.week).ceil
    start_time + weeks_ahead.weeks
  end

  private

  def generate_slug
    base = "#{totem&.slug}-#{title.parameterize}"
    candidate = base
    n = 2
    while Event.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base}-#{n}"
      n += 1
    end
    self.slug = candidate
  end

  def end_time_after_start_time
    return unless start_time && end_time
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end
end
