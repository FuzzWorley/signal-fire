require "test_helper"

class Totems::BoardsControllerTest < ActionDispatch::IntegrationTest
  test "GET /t/:slug renders show for active totem with events" do
    get totem_board_path(totems(:main_totem).slug)
    assert_response :success
  end

  test "GET /t/:slug renders empty for inactive totem" do
    get totem_board_path(totems(:inactive_totem).slug)
    assert_response :success
    assert_select "h1", text: /#{totems(:inactive_totem).name}/
  end

  test "GET /t/:slug renders empty for active totem with no events" do
    get totem_board_path(totems(:secondary_totem).slug)
    assert_response :success
    assert_select "form[action='#{empty_totem_email_captures_path}']"
  end

  test "GET /t/:slug 404 for unknown slug" do
    get totem_board_path("no-such-totem")
    assert_response :not_found
  end

  test "GET /t/:slug?dismiss_footer=1 sets cookie and redirects" do
    get totem_board_path(totems(:main_totem).slug, dismiss_footer: "1")
    assert_redirected_to totem_board_path(totems(:main_totem).slug)
    assert_equal "1", cookies[:footer_dismissed]
  end

  test "footer nudge is hidden when cookie is set" do
    cookies[:footer_dismissed] = "1"
    get totem_board_path(totems(:main_totem).slug)
    assert_response :success
    assert_select "[aria-label='Get app']", count: 0
  end

  test "app nudges are hidden by default (APP_NUDGES_ENABLED unset)" do
    get totem_board_path(totems(:main_totem).slug)
    assert_select "button", text: /Install/, count: 0
    assert_select "h2", text: /works better in the app/, count: 0
  end

  test "app nudges are hidden on empty board by default" do
    get totem_board_path(totems(:secondary_totem).slug)
    assert_select "h2", text: /works better in the app/, count: 0
  end

  test "app nudges are shown when APP_NUDGES_ENABLED=true" do
    ENV["APP_NUDGES_ENABLED"] = "true"
    get totem_board_path(totems(:main_totem).slug)
    assert_select "button", text: /Install/
    assert_select "h2", text: /works better in the app/
  ensure
    ENV.delete("APP_NUDGES_ENABLED")
  end

  test "app nudges are shown on empty board when APP_NUDGES_ENABLED=true" do
    ENV["APP_NUDGES_ENABLED"] = "true"
    get totem_board_path(totems(:secondary_totem).slug)
    assert_select "h2", text: /works better in the app/
  ensure
    ENV.delete("APP_NUDGES_ENABLED")
  end

  test "footer nudge hidden by cookie even when APP_NUDGES_ENABLED=true" do
    ENV["APP_NUDGES_ENABLED"] = "true"
    cookies[:footer_dismissed] = "1"
    get totem_board_path(totems(:main_totem).slug)
    assert_select "button", text: /Install/, count: 0
  ensure
    ENV.delete("APP_NUDGES_ENABLED")
  end

  test "account signup modal shown when nudges off and not signed in" do
    get totem_board_path(totems(:main_totem).slug)
    assert_select "h2", text: /Join Signal Fire/
    assert_select "[data-account-signup-target='modal']"
    assert_select "[data-account-signup-target='banner']"
  end

  test "account signup modal hidden when APP_NUDGES_ENABLED=true" do
    ENV["APP_NUDGES_ENABLED"] = "true"
    get totem_board_path(totems(:main_totem).slug)
    assert_select "[data-account-signup-target='modal']", count: 0
  ensure
    ENV.delete("APP_NUDGES_ENABLED")
  end

  test "account signup modal hidden when signed in" do
    user = users(:regular_user)
    user.generate_magic_link_token!
    get verify_magic_link_path, params: { token: user.magic_link_token }
    get totem_board_path(totems(:main_totem).slug)
    assert_select "[data-account-signup-target='modal']", count: 0
    assert_select "[data-account-signup-target='banner']", count: 0
  end

  test "account signup modal shown on empty board when nudges off" do
    get totem_board_path(totems(:secondary_totem).slug)
    assert_select "[data-account-signup-target='modal']"
    assert_select "[data-account-signup-target='banner']"
  end

  test "tracks totem_board_viewed with totem_id and auth_state" do
    totem = totems(:main_totem)
    tracked = []
    AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
      get totem_board_path(totem.slug)
    end
    assert_equal 1, tracked.size
    assert_equal "totem_board_viewed", tracked.first[0]
    assert_equal totem.id,   tracked.first[1][:totem_id]
    assert_equal :anonymous, tracked.first[1][:auth_state]
  end
end
