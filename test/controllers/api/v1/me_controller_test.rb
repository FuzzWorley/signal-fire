require "test_helper"

class Api::V1::MeControllerTest < ActionDispatch::IntegrationTest
  # GET /api/v1/me
  test "GET /api/v1/me returns profile" do
    get api_v1_me_path, as: :json, headers: auth_header(users(:regular_user))

    assert_response :success
    body = response.parsed_body
    assert_equal users(:regular_user).id, body["id"]
    assert_equal "user@example.com", body["email"]
    assert body.key?("push_token")
    assert body.key?("notification_prefs")
  end

  test "GET /api/v1/me returns 401 without token" do
    get api_v1_me_path, as: :json
    assert_response :unauthorized
  end

  # PATCH /api/v1/me
  test "PATCH /api/v1/me updates name" do
    patch api_v1_me_path,
          params: { name: "New Name" }, as: :json,
          headers: auth_header(users(:regular_user))

    assert_response :success
    assert_equal "New Name", response.parsed_body["name"]
    assert_equal "New Name", users(:regular_user).reload.name
  end

  # DELETE /api/v1/me
  test "DELETE /api/v1/me removes user account" do
    user = users(:follower_user)
    assert_difference "User.count", -1 do
      delete api_v1_me_path, as: :json, headers: auth_header(user)
    end
    assert_response :no_content
  end

  # GET /api/v1/me/check_ins
  test "GET /api/v1/me/check_ins returns check-in list" do
    get check_ins_api_v1_me_path, as: :json,
        headers: auth_header(users(:regular_user))

    assert_response :success
    body = response.parsed_body
    assert body.key?("check_ins")
    assert_equal 1, body["check_ins"].length
    ci = body["check_ins"].first
    assert ci["checked_in_at"].present?
    assert ci.dig("event", "title").present?
    assert ci.dig("event", "totem_slug").present?
  end

  test "GET /api/v1/me/check_ins returns empty list when no check-ins" do
    get check_ins_api_v1_me_path, as: :json,
        headers: auth_header(users(:subscriber_user))

    assert_response :success
    assert_equal [], response.parsed_body["check_ins"]
  end

  # GET /api/v1/me/subscriptions
  test "GET /api/v1/me/subscriptions returns follows and subscriptions" do
    get subscriptions_api_v1_me_path, as: :json,
        headers: auth_header(users(:both_user))

    assert_response :success
    body = response.parsed_body
    assert body.key?("totem_follows")
    assert body.key?("host_subscriptions")
    assert_equal 1, body["totem_follows"].length
    assert_equal 1, body["host_subscriptions"].length
    assert body["totem_follows"].first["totem_name"].present?
    assert body["host_subscriptions"].first["host_name"].present?
  end

  # POST /api/v1/me/push_token
  test "POST /api/v1/me/push_token registers push token" do
    patch_user = users(:regular_user)
    post push_token_api_v1_me_path,
         params: { push_token: "ExponentPushToken[abc123]" }, as: :json,
         headers: auth_header(patch_user)

    assert_response :no_content
    assert_equal "ExponentPushToken[abc123]", patch_user.reload.push_token
  end

  test "POST /api/v1/me/push_token returns 422 with blank token" do
    post push_token_api_v1_me_path,
         params: { push_token: "" }, as: :json,
         headers: auth_header(users(:regular_user))

    assert_response :unprocessable_entity
  end
end
