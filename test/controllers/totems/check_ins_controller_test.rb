require "test_helper"

class Totems::CheckInsControllerTest < ActionDispatch::IntegrationTest
  test "POST check-in for active event increments count and renders success" do
    event = events(:active_now_event)
    assert_difference "AnonymousCheckInCount.sum(:count)", 1 do
      post totem_event_check_ins_path(event.totem.slug, event.slug)
    end
    assert_redirected_to totem_event_check_in_success_path(event.totem.slug, event.slug)
    follow_redirect!
    assert_response :success
    assert_select "h1", text: /checked in/i
  end

  test "POST check-in sets cookie to prevent double-count" do
    event = events(:active_now_event)
    post totem_event_check_ins_path(event.totem.slug, event.slug)
    assert cookies["checked_in_event_#{event.id}"].present?
  end

  test "POST check-in is idempotent when cookie is already set" do
    event = events(:active_now_event)
    cookies["checked_in_event_#{event.id}"] = "1"

    assert_no_difference "AnonymousCheckInCount.sum(:count)" do
      post totem_event_check_ins_path(event.totem.slug, event.slug)
    end
    assert_redirected_to totem_event_check_in_success_path(event.totem.slug, event.slug)
  end

  test "POST check-in redirects with alert when event is not active" do
    event = events(:upcoming_event)
    post totem_event_check_ins_path(event.totem.slug, event.slug)
    assert_redirected_to totem_event_path(event.totem.slug, event.slug)
    assert flash[:alert].present?
  end

  test "tracks check_in_anonymous on first web check-in" do
    event = events(:active_now_event)
    tracked = []
    AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
      post totem_event_check_ins_path(event.totem.slug, event.slug)
    end
    assert_equal 1, tracked.size
    assert_equal "check_in_anonymous", tracked.first[0]
    assert_equal event.id,       tracked.first[1][:event_id]
    assert_equal event.totem_id, tracked.first[1][:totem_id]
  end

  test "does not track check_in_anonymous when duplicate cookie is present" do
    event = events(:active_now_event)
    cookies["checked_in_event_#{event.id}"] = "1"
    tracked = []
    AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
      post totem_event_check_ins_path(event.totem.slug, event.slug)
    end
    assert_empty tracked
  end
end
