class Event < ApplicationRecord
  belongs_to :host
  belongs_to :totem_page, optional: true
  has_many :attendances, dependent: :destroy
  has_many :attendees, through: :attendances, source: :user
  has_many :notifications, dependent: :destroy
  has_many :story_cards, dependent: :destroy

  enum :status, { draft: "draft", scheduled: "scheduled", live: "live", completed: "completed", canceled: "canceled" }

  validates :title, presence: true
  validates :start_time, presence: true
  validates :scheduled_duration_min, numericality: { greater_than: 0, less_than_or_equal_to: 240 }
end
