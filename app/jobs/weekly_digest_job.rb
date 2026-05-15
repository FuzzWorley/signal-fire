class WeeklyDigestJob < ApplicationJob
  queue_as :default

  def perform
    User.where.not(push_token: nil).find_each do |user|
      WeeklyDigestDeliveryJob.perform_later(user.id)
    end
  end
end
