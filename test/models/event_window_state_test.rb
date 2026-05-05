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

  # just_ended is still active — both window_state and active_now? must agree
  test "just_ended event is still active_now?" do
    event = build_event(start_offset: -90.minutes, end_offset: -20.minutes)
    assert_equal :just_ended, event.window_state
    assert event.active_now?
  end

  test "past event is not active_now?" do
    event = build_event(start_offset: -3.hours, end_offset: -2.hours)
    assert_equal :past, event.window_state
    assert_not event.active_now?
  end

  # timezone: Eastern time (regression for UTC storage bug)
  test "happening_now evaluated correctly in Eastern timezone" do
    travel_to Time.zone.local(2026, 5, 4, 21, 16, 0) do
      event = Event.new(
        title: "Test", totem: totems(:main_totem), host_user: users(:host_user),
        recurrence_type: :one_time,
        start_time: Time.zone.local(2026, 5, 4, 21, 15, 0),
        end_time:   Time.zone.local(2026, 5, 4, 22, 15, 0),
        chat_url: "https://chat.whatsapp.com/x", chat_platform: :whatsapp,
        status: :active
      )
      assert_equal :happening_now, event.window_state
      assert event.active_now?
    end
  end

  test "past evaluated correctly in Eastern timezone — not confused with UTC" do
    # 9:16 PM Eastern = 1:16 AM UTC next day
    # An event stored correctly in Eastern (5 PM – 7 PM) should be :past, not :happening_now
    travel_to Time.zone.local(2026, 5, 4, 21, 16, 0) do
      event = Event.new(
        title: "Test", totem: totems(:main_totem), host_user: users(:host_user),
        recurrence_type: :one_time,
        start_time: Time.zone.local(2026, 5, 4, 17, 0, 0),
        end_time:   Time.zone.local(2026, 5, 4, 19, 0, 0),
        chat_url: "https://chat.whatsapp.com/x", chat_platform: :whatsapp,
        status: :active
      )
      assert_equal :past, event.window_state
      assert_not event.active_now?
    end
  end
end
