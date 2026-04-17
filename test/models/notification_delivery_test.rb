require "test_helper"

class NotificationDeliveryTest < ActiveSupport::TestCase
  def build_delivery(overrides = {})
    NotificationDelivery.new({
      user: users(:regular_user),
      event: events(:upcoming_event),
      notification_type: :new_event,
      source_type: :totem_follow
    }.merge(overrides))
  end

  test "valid notification delivery" do
    assert build_delivery.valid?
  end

  test "notification_type is required" do
    delivery = build_delivery(notification_type: nil)
    assert_not delivery.valid?
    assert delivery.errors[:notification_type].any?
  end

  test "source_type is required" do
    delivery = build_delivery(source_type: nil)
    assert_not delivery.valid?
    assert delivery.errors[:source_type].any?
  end

  test "duplicate user + event + notification_type is invalid" do
    NotificationDelivery.create!(
      user: users(:regular_user),
      event: events(:upcoming_event),
      notification_type: :new_event,
      source_type: :totem_follow
    )
    duplicate = build_delivery
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end

  test "same user + event with different notification_type is valid" do
    NotificationDelivery.create!(
      user: users(:regular_user),
      event: events(:upcoming_event),
      notification_type: :new_event,
      source_type: :totem_follow
    )
    other = build_delivery(notification_type: :reminder)
    assert other.valid?
  end

  test "new_event? predicate" do
    assert build_delivery(notification_type: :new_event).new_event?
  end

  test "reminder? predicate" do
    assert build_delivery(notification_type: :reminder).reminder?
  end
end
