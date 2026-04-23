require "test_helper"

class Api::V1::AnonymousCheckInsControllerTest < ActionDispatch::IntegrationTest
  test "POST tracks check_in_anonymous with event_id and totem_id" do
    event = events(:active_now_event)
    tracked = []
    AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
      post api_v1_totem_event_anonymous_check_ins_path(totem_slug: event.totem.slug, event_event_slug: event.slug),
           as: :json
    end
    assert_equal 1, tracked.size
    assert_equal "check_in_anonymous", tracked.first[0]
    assert_equal event.id,        tracked.first[1][:event_id]
    assert_equal event.totem_id,  tracked.first[1][:totem_id]
  end

  test "POST does not track when event window is closed" do
    event = events(:upcoming_event)
    tracked = []
    AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
      post api_v1_totem_event_anonymous_check_ins_path(totem_slug: event.totem.slug, event_event_slug: event.slug),
           as: :json
    end
    assert_empty tracked
  end
end
