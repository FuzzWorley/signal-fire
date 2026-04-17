require "test_helper"

class EventWindowStateTest < ActiveSupport::TestCase
  def build_event(start_offset:, end_offset:, status: :active)
    Event.new(
      title: "Test", totem: totems(:main_totem), host_user: users(:host_user),
      recurrence_type: :one_time,
      start_time: Time.current + start_offset,
      end_time:   Time.current + end_offset,
      chat_url: "https://chat.whatsapp.com/x", chat_platform: :whatsapp,
      status: status
    )
  end

  test "cancelled event returns :cancelled regardless of time" do
    event = build_event(start_offset: -1.hour, end_offset: 1.hour, status: :cancelled)
    assert_equal :cancelled, event.window_state
  end

  test "before: start_time more than 30 min away" do
    event = build_event(start_offset: 2.hours, end_offset: 3.hours)
    assert_equal :before, event.window_state
  end

  test "starting_soon: start_time within 30 min but not yet started" do
    event = build_event(start_offset: 20.minutes, end_offset: 80.minutes)
    assert_equal :starting_soon, event.window_state
  end

  test "happening_now: between start and end" do
    event = build_event(start_offset: -15.minutes, end_offset: 45.minutes)
    assert_equal :happening_now, event.window_state
  end

  test "just_ended: end_time within 30 min ago" do
    event = build_event(start_offset: -90.minutes, end_offset: -20.minutes)
    assert_equal :just_ended, event.window_state
  end

  test "past: end_time more than 30 min ago" do
    event = build_event(start_offset: -3.hours, end_offset: -2.hours)
    assert_equal :past, event.window_state
  end
end
