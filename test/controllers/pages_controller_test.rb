require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "GET /about renders about page" do
    get about_path
    assert_response :success
    assert_select "h1", text: /about/i
  end
end
