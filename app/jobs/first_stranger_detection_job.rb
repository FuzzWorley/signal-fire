class FirstStrangerDetectionJob < ApplicationJob
  queue_as :default

  def perform(check_in_id)
    check_in  = CheckIn.includes(:event).find(check_in_id)
    host_user = check_in.event.host_user

    first_seen = UserHostFirstSeen.find_or_initialize_by(
      user:      check_in.user,
      host_user: host_user
    )
    return unless first_seen.new_record?

    first_seen.update!(first_seen_at: check_in.checked_in_at)
    FirstStrangerNotificationJob.perform_later(check_in_id)
  end
end
