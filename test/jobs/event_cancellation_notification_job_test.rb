require "test_helper"

class EventCancellationNotificationJobTest < ActiveSupport::TestCase
  EXPECTED_RECIPIENT_COUNT = 3

  setup do
    @event = events(:upcoming_event)
    @event.update_column(:status, "cancelled")
  end

  test "creates cancelled NotificationDeliveries for all recipients" do
    assert_difference "NotificationDelivery.where(notification_type: 'cancelled').count",
                      EXPECTED_RECIPIENT_COUNT do
      EventCancellationNotificationJob.new.perform(@event.id)
    end
  end

  test "both_user attributed to host_subscription" do
    EventCancellationNotificationJob.new.perform(@event.id)
    delivery = NotificationDelivery.find_by(
      user: users(:both_user), event: @event, notification_type: "cancelled"
    )
    assert_not_nil delivery
    assert delivery.host_subscription?
  end

  test "does not create duplicate deliveries on retry" do
    EventCancellationNotificationJob.new.perform(@event.id)
    count = NotificationDelivery.count
    EventCancellationNotificationJob.new.perform(@event.id)
    assert_equal count, NotificationDelivery.count
  end

  test "skips delivery for weekly events" do
    weekly = events(:weekly_event)
    weekly.update_column(:status, "cancelled")
    assert_no_difference "NotificationDelivery.count" do
      EventCancellationNotificationJob.new.perform(weekly.id)
    end
  end

  test "skips delivery when event is still active" do
    active_event = events(:active_now_event)
    assert_no_difference "NotificationDelivery.count" do
      EventCancellationNotificationJob.new.perform(active_event.id)
    end
  end

  test "silently returns when event is not found" do
    assert_nothing_raised { EventCancellationNotificationJob.new.perform(-1) }
  end
end
