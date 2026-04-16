class PushToken < ApplicationRecord
  belongs_to :user

  enum :platform, { ios: "ios", android: "android" }

  validates :token, presence: true, uniqueness: true
  validates :platform, presence: true
end
