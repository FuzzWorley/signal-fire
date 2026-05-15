require "test_helper"

class FirstStrangerNotificationJobTest < ActiveSupport::TestCase
  setup do
    @event    = events(:upcoming_event)
    @host     = users(:host_user)
    @attendee = users(:regular_user)
    @check_in = CheckIn.create!(
      user:          @attendee,
      event:         @event,
      checked_in_at: Time.current
    )
    @host.update_column(:push_token, "ExponentPushToken[host-token]")
  end

  test "sends push notification and creates delivery on first check-in" do
    ok_result = PushNotificationService::Result.new(ok: true, error: nil)
    PushNotificationService.stub(:deliver, ok_result) do
      assert_difference "NotificationDelivery.where(notification_type: 'first_stranger').count", 1 do
        FirstStrangerNotificationJob.new.perform(@check_in.id)
      end
    end
  end

  test "delivery record has direct source_type" do
    ok_result = PushNotificationService::Result.new(ok: true, error: nil)
    PushNotificationService.stub(:deliver, ok_result) do
      FirstStrangerNotificationJob.new.perform(@check_in.id)
    end
    delivery = NotificationDelivery.find_by(
      user:              @host,
      event:             @event,
      notification_type: "first_stranger"
    )
    assert_not_nil delivery
    assert delivery.direct?
  end

  test "does not send a second push for the same event (one-per-event cap)" do
    NotificationDelivery.create!(
      user:              @host,
      event:             @event,
      notification_type: :first_stranger,
      source_type:       :direct,
      sent_at:           1.minute.ago
    )

    delivered = false
    PushNotificationService.stub(:deliver, ->(**) { delivered = true; PushNotificationService::Result.new(ok: true, error: nil) }) do
      FirstStrangerNotificationJob.new.perform(@check_in.id)
    end
    assert_not delivered
  end

  test "skips push when host has no push token" do
    @host.update_column(:push_token, nil)

    delivered = false
    PushNotificationService.stub(:deliver, ->(**) { delivered = true; PushNotificationService::Result.new(ok: true, error: nil) }) do
      FirstStrangerNotificationJob.new.perform(@check_in.id)
    end
    assert_not delivered
  end

  test "clears push token when Expo returns DeviceNotRegistered" do
    dead_result = PushNotificationService::Result.new(ok: false, error: "DeviceNotRegistered")
    PushNotificationService.stub(:deliver, dead_result) do
      FirstStrangerNotificationJob.new.perform(@check_in.id)
    end
    assert_nil @host.reload.push_token
  end
end
