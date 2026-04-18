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
end
