require "test_helper"

class NewEventNotificationJobTest < ActiveSupport::TestCase
  # subscriber_user (host_sub) + follower_user (totem_follow) + both_user (host_sub, deduped) = 3
  EXPECTED_RECIPIENT_COUNT = 3

  setup do
    @event = events(:upcoming_event)
  end

  test "creates one NotificationDelivery per unique recipient" do
    assert_difference "NotificationDelivery.count", EXPECTED_RECIPIENT_COUNT do
      NewEventNotificationJob.new.perform(@event.id)
    end
  end

  test "subscriber_user gets new_event delivery attributed to host_subscription" do
    NewEventNotificationJob.new.perform(@event.id)
    delivery = NotificationDelivery.find_by(user: users(:subscriber_user), event: @event)
    assert_not_nil delivery
    assert delivery.new_event?
    assert delivery.host_subscription?
  end

  test "follower_user gets new_event delivery attributed to totem_follow" do
    NewEventNotificationJob.new.perform(@event.id)
    delivery = NotificationDelivery.find_by(user: users(:follower_user), event: @event)
    assert_not_nil delivery
    assert delivery.new_event?
    assert delivery.totem_follow?
  end

  test "both_user gets only one delivery attributed to host_subscription" do
    NewEventNotificationJob.new.perform(@event.id)
    deliveries = NotificationDelivery.where(user: users(:both_user), event: @event)
    assert_equal 1, deliveries.count
    assert deliveries.first.host_subscription?
  end

  test "does not create duplicate deliveries on retry" do
    NewEventNotificationJob.new.perform(@event.id)
    count_after_first = NotificationDelivery.count
    NewEventNotificationJob.new.perform(@event.id)
    assert_equal count_after_first, NotificationDelivery.count
  end

  test "skips all deliveries for cancelled event" do
    @event.update_column(:status, "cancelled")
    assert_no_difference "NotificationDelivery.count" do
      NewEventNotificationJob.new.perform(@event.id)
    end
  end

  test "silently returns when event is not found" do
    assert_nothing_raised { NewEventNotificationJob.new.perform(-1) }
  end

  test "tracks notification_sent for each recipient that has a push token" do
    # Give all recipients a push token so deliver_to reaches the analytics call.
    [ users(:subscriber_user), users(:follower_user), users(:both_user) ].each do |u|
      u.update_column(:push_token, "ExponentPushToken[test_#{u.id}]")
    end
    PushNotificationService.stub(:deliver, true) do
      tracked = []
      AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
        NewEventNotificationJob.new.perform(@event.id)
      end
      assert_equal EXPECTED_RECIPIENT_COUNT, tracked.size
      assert tracked.all? { |name, _| name == "notification_sent" }
      assert tracked.all? { |_, props| props[:event_id] == @event.id }
      assert tracked.all? { |_, props| props[:type] == :new_event }
    end
  end
end
