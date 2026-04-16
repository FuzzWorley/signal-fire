class TotemPage < ApplicationRecord
  belongs_to :host
  has_many :events, dependent: :nullify

  before_validation :generate_slug, if: -> { slug.blank? && group_name.present? }

  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers, and hyphens" }
  validates :group_name, presence: true

  private

  def generate_slug
    base = group_name.parameterize
    candidate = base
    n = 2
    while TotemPage.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base}-#{n}"
      n += 1
    end
    self.slug = candidate
  end
end
