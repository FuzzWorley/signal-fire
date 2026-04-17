require "test_helper"

class CheckInTest < ActiveSupport::TestCase
  def build_check_in(overrides = {})
    CheckIn.new({
      user: users(:regular_user),
      event: events(:upcoming_event)
    }.merge(overrides))
  end

  test "checked_in_at is auto-set before validation" do
    check_in = build_check_in
    check_in.valid?
    assert_not_nil check_in.checked_in_at
  end

  test "checked_in_at is not overwritten when already set" do
    time = 5.minutes.ago
    check_in = build_check_in(checked_in_at: time)
    check_in.valid?
    assert_in_delta time.to_i, check_in.checked_in_at.to_i, 1
  end

  test "duplicate user + event is invalid" do
    CheckIn.create!(user: users(:regular_user), event: events(:upcoming_event))
    duplicate = build_check_in
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end

  test "same user can check in to different events" do
    CheckIn.create!(user: users(:regular_user), event: events(:upcoming_event))
    other = build_check_in(event: events(:past_event))
    assert other.valid?
  end
end
