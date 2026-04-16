class Host < ApplicationRecord
  belongs_to :user
  belongs_to :approved_by_admin, class_name: "User", optional: true
  has_many :totem_pages, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :reputations, dependent: :destroy
  has_many :notifications, through: :events

  validates :name, presence: true
end
