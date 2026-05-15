require "test_helper"

class FirstStrangerDetectionJobTest < ActiveSupport::TestCase
  setup do
    @event    = events(:upcoming_event)   # host_user = users(:host_user)
    @attendee = users(:regular_user)
    @check_in = CheckIn.create!(
      user:          @attendee,
      event:         @event,
      checked_in_at: Time.current
    )
  end

  test "creates UserHostFirstSeen on first check-in for this attendee/host pair" do
    assert_difference "UserHostFirstSeen.count", 1 do
      FirstStrangerDetectionJob.new.perform(@check_in.id)
    end

    record = UserHostFirstSeen.find_by(user: @attendee, host_user: @event.host_user)
    assert_not_nil record
    assert_in_delta @check_in.checked_in_at.to_i, record.first_seen_at.to_i, 2
  end

  test "enqueues FirstStrangerNotificationJob on first check-in" do
    assert_enqueued_with(job: FirstStrangerNotificationJob, args: [@check_in.id]) do
      FirstStrangerDetectionJob.new.perform(@check_in.id)
    end
  end

  test "does not create duplicate UserHostFirstSeen on repeat check-in" do
    UserHostFirstSeen.create!(
      user:         @attendee,
      host_user:    @event.host_user,
      first_seen_at: 1.week.ago
    )

    assert_no_difference "UserHostFirstSeen.count" do
      FirstStrangerDetectionJob.new.perform(@check_in.id)
    end
  end

  test "does not enqueue notification job on repeat check-in" do
    UserHostFirstSeen.create!(
      user:         @attendee,
      host_user:    @event.host_user,
      first_seen_at: 1.week.ago
    )

    assert_no_enqueued_jobs only: FirstStrangerNotificationJob do
      FirstStrangerDetectionJob.new.perform(@check_in.id)
    end
  end
end
