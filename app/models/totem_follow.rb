class TotemFollow < ApplicationRecord
  belongs_to :user
  belongs_to :totem

  validates :user_id, uniqueness: { scope: :totem_id }
end
