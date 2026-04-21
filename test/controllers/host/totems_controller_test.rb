require "test_helper"

class Host::TotemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = users(:host_user)
    post host_login_path, params: { email: @host.email, password: "password123" }
  end

  test "GET /host/totems renders assigned totems" do
    get host_totems_path
    assert_response :success
    assert_select "h1", text: /totems/i
  end

  test "GET /host/totems redirects unauthenticated user" do
    delete host_logout_path
    get host_totems_path
    assert_redirected_to host_login_path
  end
end
