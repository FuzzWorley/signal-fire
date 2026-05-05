require "test_helper"

class EventTest < ActiveSupport::TestCase
  def build_event(overrides = {})
    Event.new({
      title: "Test Event",
      totem: Totem.new(name: "Test Totem"),
      host_user: users(:host_user),
      recurrence_type: :one_time,
      start_time: 1.hour.from_now,
      end_time: 2.hours.from_now,
      chat_url: "https://chat.whatsapp.com/abc123",
      chat_platform: :whatsapp,
      status: :active
    }.merge(overrides))
  end

  # active_now?
  test "active_now? true when current time is within window" do
    event = build_event(start_time: 20.minutes.ago, end_time: 40.minutes.from_now)
    assert event.active_now?
  end

  test "active_now? true when within before-window" do
    event = build_event(start_time: 25.minutes.from_now, end_time: 85.minutes.from_now)
    assert event.active_now?
  end

  test "active_now? true when within after-window" do
    event = build_event(start_time: 90.minutes.ago, end_time: 25.minutes.ago)
    assert event.active_now?
  end

  test "active_now? false when before window" do
    event = build_event(start_time: 2.hours.from_now, end_time: 3.hours.from_now)
    assert_not event.active_now?
  end

  test "active_now? false when after window" do
    event = build_event(start_time: 3.hours.ago, end_time: 2.hours.ago)
    assert_not event.active_now?
  end

  # next_occurrence
  test "next_occurrence returns start_time for one_time events" do
    start = 1.hour.from_now
    event = build_event(recurrence_type: :one_time, start_time: start, end_time: start + 1.hour)
    assert_equal start, event.next_occurrence
  end

  test "next_occurrence returns start_time for future weekly events" do
    start = 1.day.from_now
    event = build_event(recurrence_type: :weekly, start_time: start, end_time: start + 1.hour)
    assert_equal start, event.next_occurrence
  end

  test "next_occurrence projects weekly event forward from past anchor" do
    start = 3.weeks.ago
    event = build_event(recurrence_type: :weekly, start_time: start, end_time: start + 1.hour)
    next_occ = event.next_occurrence
    assert next_occ > Time.current
    assert_in_delta 0, (next_occ - start).to_i % 1.week.to_i, 60
  end

  # validations
  test "end_time must be after start_time" do
    event = build_event(start_time: 2.hours.from_now, end_time: 1.hour.from_now)
    assert_not event.valid?
    assert event.errors[:end_time].any?
  end

  test "chat_platform is optional" do
    event = build_event(chat_platform: nil, chat_url: nil)
    assert event.valid?
  end

  test "chat_url not required when chat_platform is blank" do
    event = build_event(chat_platform: nil, chat_url: nil)
    event.valid?
    assert_not event.errors[:chat_url].any?
  end

  test "chat_url required when chat_platform is set" do
    event = build_event(chat_platform: :whatsapp, chat_url: nil)
    assert_not event.valid?
    assert event.errors[:chat_url].any?
  end

  test "chat_url format validated against selected platform" do
    event = build_event(chat_platform: :discord, chat_url: "https://chat.whatsapp.com/abc")
    assert_not event.valid?
    assert event.errors[:chat_url].any?
  end

  test "slug auto-generated from totem slug and title" do
    totem = Totem.new(name: "My Totem")
    totem.valid? # triggers before_validation slug generation
    event = build_event(title: "Morning Run", totem: totem)
    event.valid?
    assert_match(/my-totem-morning-run/, event.slug)
  end

  # timezone
  test "active_now? true for event happening now in Eastern time" do
    travel_to Time.zone.local(2026, 5, 4, 21, 16, 0) do
      event = build_event(
        start_time: Time.zone.local(2026, 5, 4, 21, 15, 0),
        end_time:   Time.zone.local(2026, 5, 4, 22, 15, 0)
      )
      assert event.active_now?
    end
  end

  test "active_now? false for event that ended hours ago in Eastern time" do
    travel_to Time.zone.local(2026, 5, 4, 21, 16, 0) do
      event = build_event(
        start_time: Time.zone.local(2026, 5, 4, 17, 15, 0),
        end_time:   Time.zone.local(2026, 5, 4, 19, 15, 0)
      )
      assert_not event.active_now?
    end
  end
end
