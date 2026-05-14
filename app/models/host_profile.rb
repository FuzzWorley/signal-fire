class HostProfile < ApplicationRecord
  belongs_to :user

  enum :invite_status, { invited: "invited", active: "active", deactivated: "deactivated" }

  validates :display_name, presence: true
  validates :invite_status, presence: true
  validates :slug, uniqueness: true, allow_nil: true,
                   format: { with: /\A[a-z0-9\-]+\z/, message: "only lowercase letters, numbers, and hyphens" }

  before_validation :generate_slug, if: -> { slug.blank? && display_name.present? }

  private

  def generate_slug
    base = display_name.parameterize
    candidate = base
    n = 2
    while HostProfile.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base}-#{n}"
      n += 1
    end
    self.slug = candidate
  end
end
