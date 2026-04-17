require "test_helper"

class Totems::EventsControllerTest < ActionDispatch::IntegrationTest
  test "GET /t/:slug/e/:event_slug renders event detail" do
    event = events(:upcoming_event)
    get totem_event_path(event.totem.slug, event.slug)
    assert_response :success
    assert_select "h1", text: /#{event.title}/
  end

  test "GET /t/:slug/e/:event_slug shows cancelled banner for cancelled event" do
    event = events(:cancelled_event)
    get totem_event_path(event.totem.slug, event.slug)
    assert_response :success
    assert_select "[role='alert']", text: /cancelled/i
  end

  test "GET /t/:slug/e/:event_slug 404 for unknown event slug" do
    get totem_event_path(totems(:main_totem).slug, "no-such-event")
    assert_response :not_found
  end

  test "GET /t/:slug/e/:event_slug 404 when event belongs to different totem" do
    event = events(:upcoming_event)
    get totem_event_path(totems(:secondary_totem).slug, event.slug)
    assert_response :not_found
  end

  test "check-in button visible for active_now event" do
    event = events(:active_now_event)
    get totem_event_path(event.totem.slug, event.slug)
    assert_response :success
    assert_select "input[value='Check in anonymously']"
  end

  test "check-in button hidden for upcoming event" do
    event = events(:upcoming_event)
    get totem_event_path(event.totem.slug, event.slug)
    assert_response :success
    assert_select "input[value='Check in anonymously']", count: 0
  end
end
