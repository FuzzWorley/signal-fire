class StoryCard < ApplicationRecord
  belongs_to :event

  enum :card_type, { preview: "preview", live: "live", recap: "recap" }
  enum :status, { pending: "pending", generating: "generating", ready: "ready", failed: "failed" }

  validates :card_type, presence: true
end
