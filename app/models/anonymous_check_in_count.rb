class AnonymousCheckInCount < ApplicationRecord
  belongs_to :event

  validates :count, numericality: { greater_than_or_equal_to: 0 }
end
