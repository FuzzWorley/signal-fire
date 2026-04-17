class HostProfile < ApplicationRecord
  belongs_to :user

  enum :invite_status, { invited: "invited", active: "active", deactivated: "deactivated" }

  validates :display_name, presence: true
  validates :invite_status, presence: true
end
