require "test_helper"

class PreEventReminderJobTest < ActiveSupport::TestCase
  EXPECTED_RECIPIENT_COUNT = 3

  setup do
    @event = events(:upcoming_event)
  end

  test "creates reminder NotificationDeliveries for all recipients" do
    assert_difference "NotificationDelivery.where(notification_type: 'reminder').count",
                      EXPECTED_RECIPIENT_COUNT do
      PreEventReminderJob.new.perform(@event.id)
    end
  end

  test "subscriber_user reminder attributed to host_subscription" do
    PreEventReminderJob.new.perform(@event.id)
    delivery = NotificationDelivery.find_by(
      user: users(:subscriber_user), event: @event, notification_type: "reminder"
    )
    assert_not_nil delivery
    assert delivery.host_subscription?
  end

  test "does not create duplicate deliveries on retry" do
    PreEventReminderJob.new.perform(@event.id)
    count = NotificationDelivery.count
    PreEventReminderJob.new.perform(@event.id)
    assert_equal count, NotificationDelivery.count
  end

  test "skips all deliveries for cancelled event" do
    @event.update_column(:status, "cancelled")
    assert_no_difference "NotificationDelivery.count" do
      PreEventReminderJob.new.perform(@event.id)
    end
  end

  test "does not enqueue next reminder for one-time event" do
    assert_no_enqueued_jobs only: PreEventReminderJob do
      PreEventReminderJob.new.perform(@event.id)
    end
  end

  test "enqueues next reminder for weekly event" do
    weekly = events(:weekly_event)
    assert_enqueued_with(job: PreEventReminderJob, args: [weekly.id]) do
      PreEventReminderJob.new.perform(weekly.id)
    end
  end

  test "silently returns when event is not found" do
    assert_nothing_raised { PreEventReminderJob.new.perform(-1) }
  end
end
