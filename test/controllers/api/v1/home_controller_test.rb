require "test_helper"

class Api::V1::HomeControllerTest < ActionDispatch::IntegrationTest
  test "GET /api/v1/home returns boards for followed totems" do
    get api_v1_home_path, as: :json, headers: auth_header(users(:follower_user))

    assert_response :success
    body = response.parsed_body
    assert body.key?("boards")
    assert_equal 1, body["boards"].length
    board = body["boards"].first
    assert_equal "main-totem", board["totem_slug"]
  end

  test "boards list is empty when user follows nothing" do
    get api_v1_home_path, as: :json, headers: auth_header(users(:regular_user))

    assert_response :success
    assert_equal [], response.parsed_body["boards"]
  end

  test "board includes active_event when totem has happening now event" do
    get api_v1_home_path, as: :json, headers: auth_header(users(:follower_user))

    board = response.parsed_body["boards"].first
    assert_not_nil board["active_event"]
    assert_equal events(:active_now_event).slug, board["active_event"]["slug"]
  end

  test "board includes next_event" do
    get api_v1_home_path, as: :json, headers: auth_header(users(:follower_user))

    board = response.parsed_body["boards"].first
    assert_not_nil board["next_event"]
  end

  test "returns 401 without token" do
    get api_v1_home_path, as: :json
    assert_response :unauthorized
  end
end
