class Reputation < ApplicationRecord
  belongs_to :user
  belongs_to :host

  validates :total_count, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: :host_id }
end
