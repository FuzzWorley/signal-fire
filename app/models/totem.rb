class Totem < ApplicationRecord
  has_many :host_totem_assignments
  has_many :hosts, through: :host_totem_assignments, source: :host_user
  has_many :events
  has_many :totem_follows
  has_many :empty_totem_email_captures

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers, and hyphens" }

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

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
