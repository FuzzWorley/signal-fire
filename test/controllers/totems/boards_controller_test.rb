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
end
