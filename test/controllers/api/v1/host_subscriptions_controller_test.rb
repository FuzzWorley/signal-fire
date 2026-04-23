require "test_helper"

class Api::V1::HostSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "POST /api/v1/host_subscriptions creates subscription" do
    assert_difference "HostSubscription.count", 1 do
      post api_v1_host_subscriptions_path,
           params: { host_user_id: users(:host_user).id },
           as: :json,
           headers: auth_header(users(:regular_user))
    end
    assert_response :created
    body = response.parsed_body
    assert_equal users(:host_user).id, body["host_user_id"]
    assert_equal true, body["notify_new_event"]
  end

  test "POST is idempotent — returns existing subscription" do
    assert_no_difference "HostSubscription.count" do
      post api_v1_host_subscriptions_path,
           params: { host_user_id: users(:host_user).id },
           as: :json,
           headers: auth_header(users(:subscriber_user))
    end
    assert_response :success
  end

  test "POST returns 404 for unknown host" do
    post api_v1_host_subscriptions_path,
         params: { host_user_id: -1 }, as: :json,
         headers: auth_header(users(:regular_user))
    assert_response :not_found
  end

  test "POST returns 404 when target is not a host" do
    post api_v1_host_subscriptions_path,
         params: { host_user_id: users(:regular_user).id }, as: :json,
         headers: auth_header(users(:subscriber_user))
    assert_response :not_found
  end

  test "PATCH /api/v1/host_subscriptions/:id updates notification prefs" do
    sub = host_subscriptions(:subscriber_follows_host)
    patch api_v1_host_subscription_path(sub),
          params: { notify_reminder: false }, as: :json,
          headers: auth_header(users(:subscriber_user))
    assert_response :success
    assert_equal false, response.parsed_body["notify_reminder"]
  end

  test "DELETE /api/v1/host_subscriptions/:id destroys subscription" do
    sub = host_subscriptions(:subscriber_follows_host)
    assert_difference "HostSubscription.count", -1 do
      delete api_v1_host_subscription_path(sub),
             as: :json, headers: auth_header(users(:subscriber_user))
    end
    assert_response :no_content
  end

  test "DELETE returns 404 for another user's subscription" do
    sub = host_subscriptions(:subscriber_follows_host)
    delete api_v1_host_subscription_path(sub),
           as: :json, headers: auth_header(users(:regular_user))
    assert_response :not_found
  end

  test "returns 401 without token" do
    post api_v1_host_subscriptions_path,
         params: { host_user_id: users(:host_user).id }, as: :json
    assert_response :unauthorized
  end

  test "tracks host_subscribed with correct properties on new subscription" do
    host = users(:host_user)
    user = users(:regular_user)
    tracked = []
    AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
      post api_v1_host_subscriptions_path,
           params: { host_user_id: host.id }, as: :json,
           headers: auth_header(user)
    end
    assert_equal 1, tracked.size
    assert_equal "host_subscribed", tracked.first[0]
    assert_equal user.id, tracked.first[1][:user_id]
    assert_equal host.id, tracked.first[1][:host_user_id]
  end

  test "does not track host_subscribed on duplicate subscription" do
    tracked = []
    AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
      post api_v1_host_subscriptions_path,
           params: { host_user_id: users(:host_user).id }, as: :json,
           headers: auth_header(users(:subscriber_user))
    end
    assert_empty tracked
  end

  test "tracks host_unsubscribed with correct properties on DELETE" do
    sub  = host_subscriptions(:subscriber_follows_host)
    user = users(:subscriber_user)
    tracked = []
    AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
      delete api_v1_host_subscription_path(sub),
             as: :json, headers: auth_header(user)
    end
    assert_equal 1, tracked.size
    assert_equal "host_unsubscribed", tracked.first[0]
    assert_equal user.id,            tracked.first[1][:user_id]
    assert_equal sub.host_user_id,   tracked.first[1][:host_user_id]
  end
end
