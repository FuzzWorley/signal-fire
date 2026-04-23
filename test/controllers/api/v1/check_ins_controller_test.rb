require "test_helper"

class Api::V1::CheckInsControllerTest < ActionDispatch::IntegrationTest
  test "POST /api/v1/events/:event_id/check_ins creates check-in during window" do
    event = events(:active_now_event)
    assert_difference "CheckIn.count", 1 do
      post api_v1_event_check_ins_path(event_id: event.id),
           as: :json, headers: auth_header(users(:subscriber_user))
    end
    assert_response :created
    body = response.parsed_body
    assert_equal true, body["checked_in"]
    assert body["checked_in_at"].present?
  end

  test "POST is idempotent — returns 200 if already checked in" do
    event = events(:active_now_event)
    assert_no_difference "CheckIn.count" do
      post api_v1_event_check_ins_path(event_id: event.id),
           as: :json, headers: auth_header(users(:regular_user))
    end
    assert_response :success
    assert_equal true, response.parsed_body["checked_in"]
  end

  test "returns 422 when check-in window is closed" do
    event = events(:upcoming_event)
    post api_v1_event_check_ins_path(event_id: event.id),
         as: :json, headers: auth_header(users(:regular_user))
    assert_response :unprocessable_entity
    assert response.parsed_body["error"].present?
  end

  test "returns 401 without token" do
    post api_v1_event_check_ins_path(event_id: events(:active_now_event).id), as: :json
    assert_response :unauthorized
  end

  test "returns 404 for unknown event" do
    post api_v1_event_check_ins_path(event_id: -1),
         as: :json, headers: auth_header(users(:regular_user))
    assert_response :not_found
  end

  test "tracks check_in_authenticated with correct properties on new check-in" do
    event = events(:active_now_event)
    user  = users(:subscriber_user)
    tracked = []
    AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
      post api_v1_event_check_ins_path(event_id: event.id),
           as: :json, headers: auth_header(user)
    end
    assert_equal 1, tracked.size
    assert_equal "check_in_authenticated", tracked.first[0]
    assert_equal user.id,    tracked.first[1][:user_id]
    assert_equal event.id,   tracked.first[1][:event_id]
    assert_equal event.totem_id, tracked.first[1][:totem_id]
  end

  test "does not track check_in_authenticated on duplicate check-in" do
    event = events(:active_now_event)
    tracked = []
    AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
      post api_v1_event_check_ins_path(event_id: event.id),
           as: :json, headers: auth_header(users(:regular_user))
    end
    assert_empty tracked
  end
end
