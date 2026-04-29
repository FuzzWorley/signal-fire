require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "GET /about renders about page" do
    get about_path
    assert_response :success
    assert_select "h1", text: /permission structure/i
  end

  test "get the app nav link hidden by default" do
    get about_path
    assert_select "a", text: /Get the app/i, count: 0
  end

  test "get the app nav link shown when APP_NUDGES_ENABLED=true" do
    ENV["APP_NUDGES_ENABLED"] = "true"
    get about_path
    assert_select "a", text: /Get the app/i
  ensure
    ENV.delete("APP_NUDGES_ENABLED")
  end
end
