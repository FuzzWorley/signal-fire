require "test_helper"

class Api::V1::TotemsControllerTest < ActionDispatch::IntegrationTest
  test "GET /api/v1/totems/:slug returns totem board anonymously" do
    get api_v1_totem_path(slug: totems(:main_totem).slug), as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal "Main Totem", body.dig("totem", "name")
    assert_equal "main-totem", body.dig("totem", "slug")
    assert body["totem"].key?("active_now")
    assert body["totem"].key?("upcoming")
  end

  test "GET /api/v1/totems/:slug returns 404 for unknown slug" do
    get api_v1_totem_path(slug: "does-not-exist"), as: :json
    assert_response :not_found
  end

  test "following is null when unauthenticated" do
    get api_v1_totem_path(slug: totems(:main_totem).slug), as: :json
    assert_nil response.parsed_body.dig("totem", "following")
  end

  test "following is false when authenticated and not following" do
    get api_v1_totem_path(slug: totems(:main_totem).slug), as: :json,
        headers: auth_header(users(:regular_user))
    assert_equal false, response.parsed_body.dig("totem", "following")
  end

  test "following is true when authenticated and following" do
    get api_v1_totem_path(slug: totems(:main_totem).slug), as: :json,
        headers: auth_header(users(:follower_user))
    assert_equal true, response.parsed_body.dig("totem", "following")
  end

  test "upcoming array includes upcoming_event" do
    get api_v1_totem_path(slug: totems(:main_totem).slug), as: :json
    slugs = response.parsed_body.dig("totem", "upcoming").map { |e| e["slug"] }
    assert_includes slugs, events(:upcoming_event).slug
  end

  test "active_now array includes active_now_event" do
    get api_v1_totem_path(slug: totems(:main_totem).slug), as: :json
    slugs = response.parsed_body.dig("totem", "active_now").map { |e| e["slug"] }
    assert_includes slugs, events(:active_now_event).slug
  end

  test "event includes host name" do
    get api_v1_totem_path(slug: totems(:main_totem).slug), as: :json
    event = response.parsed_body.dig("totem", "upcoming").first
    assert event.dig("host", "name").present?
  end

  test "user_checked_in is null when unauthenticated" do
    get api_v1_totem_path(slug: totems(:main_totem).slug), as: :json
    event = response.parsed_body.dig("totem", "active_now").first
    assert_nil event["user_checked_in"]
  end

  test "user_checked_in is true when authenticated user has checked in" do
    get api_v1_totem_path(slug: totems(:main_totem).slug), as: :json,
        headers: auth_header(users(:regular_user))
    event = response.parsed_body.dig("totem", "active_now")
              .find { |e| e["slug"] == events(:active_now_event).slug }
    assert_equal true, event["user_checked_in"]
  end

  test "user_checked_in is false when authenticated user has not checked in" do
    get api_v1_totem_path(slug: totems(:main_totem).slug), as: :json,
        headers: auth_header(users(:subscriber_user))
    event = response.parsed_body.dig("totem", "active_now")
              .find { |e| e["slug"] == events(:active_now_event).slug }
    assert_equal false, event["user_checked_in"]
  end

  test "cancelled events are excluded from board" do
    get api_v1_totem_path(slug: totems(:main_totem).slug), as: :json
    all_slugs = response.parsed_body.dig("totem", "active_now").map { |e| e["slug"] } +
                response.parsed_body.dig("totem", "upcoming").map { |e| e["slug"] }
    assert_not_includes all_slugs, events(:cancelled_event).slug
  end
end
