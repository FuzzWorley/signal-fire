require "test_helper"

class Api::V1::TotemFollowsControllerTest < ActionDispatch::IntegrationTest
  test "POST /api/v1/totem_follows creates follow" do
    assert_difference "TotemFollow.count", 1 do
      post api_v1_totem_follows_path,
           params: { totem_id: totems(:secondary_totem).id },
           as: :json,
           headers: auth_header(users(:regular_user))
    end
    assert_response :created
    body = response.parsed_body
    assert_equal totems(:secondary_totem).id, body["totem_id"]
    assert_equal true, body["notify_new_event"]
  end

  test "POST is idempotent — returns existing follow" do
    assert_no_difference "TotemFollow.count" do
      post api_v1_totem_follows_path,
           params: { totem_id: totems(:main_totem).id },
           as: :json,
           headers: auth_header(users(:follower_user))
    end
    assert_response :success
  end

  test "POST returns 404 for unknown totem" do
    post api_v1_totem_follows_path,
         params: { totem_id: -1 }, as: :json,
         headers: auth_header(users(:regular_user))
    assert_response :not_found
  end

  test "PATCH /api/v1/totem_follows/:id updates notification prefs" do
    follow = totem_follows(:follower_follows_main)
    patch api_v1_totem_follow_path(follow),
          params: { notify_reminder: false }, as: :json,
          headers: auth_header(users(:follower_user))
    assert_response :success
    assert_equal false, response.parsed_body["notify_reminder"]
  end

  test "DELETE /api/v1/totem_follows/:id destroys follow" do
    follow = totem_follows(:follower_follows_main)
    assert_difference "TotemFollow.count", -1 do
      delete api_v1_totem_follow_path(follow),
             as: :json, headers: auth_header(users(:follower_user))
    end
    assert_response :no_content
  end

  test "DELETE returns 404 for another user's follow" do
    follow = totem_follows(:follower_follows_main)
    delete api_v1_totem_follow_path(follow),
           as: :json, headers: auth_header(users(:regular_user))
    assert_response :not_found
  end

  test "returns 401 without token" do
    post api_v1_totem_follows_path,
         params: { totem_id: totems(:main_totem).id }, as: :json
    assert_response :unauthorized
  end
end
