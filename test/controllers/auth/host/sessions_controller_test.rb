require "test_helper"

class Auth::Host::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "GET /host/login renders login form" do
    get host_login_path
    assert_response :success
  end

  test "POST /host/login signs in active host with correct credentials" do
    post host_login_path, params: { email: "host@example.com", password: "password123" }
    assert_equal users(:host_user).id, session[:user_id]
  end

  test "POST /host/login is case-insensitive on email" do
    post host_login_path, params: { email: "HOST@EXAMPLE.COM", password: "password123" }
    assert_equal users(:host_user).id, session[:user_id]
  end

  test "POST /host/login rejects wrong password" do
    post host_login_path, params: { email: "host@example.com", password: "wrongpassword" }
    assert_nil session[:user_id]
    assert_response :unprocessable_entity
  end

  test "POST /host/login rejects non-host user" do
    post host_login_path, params: { email: "user@example.com", password: "password123" }
    assert_nil session[:user_id]
    assert_response :unprocessable_entity
  end

  test "POST /host/login rejects deactivated host" do
    post host_login_path, params: { email: "deactivated@example.com", password: "password123" }
    assert_nil session[:user_id]
    assert_response :unprocessable_entity
  end

  test "POST /host/login rejects unknown email" do
    post host_login_path, params: { email: "nobody@example.com", password: "password123" }
    assert_nil session[:user_id]
    assert_response :unprocessable_entity
  end

  test "DELETE /host/logout clears session and redirects to login" do
    post host_login_path, params: { email: "host@example.com", password: "password123" }
    delete host_logout_path
    assert_nil session[:user_id]
    assert_redirected_to host_login_path
  end

  test "POST /host/login tracks host_logged_in with user_id on success" do
    user = users(:host_user)
    tracked = []
    AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
      post host_login_path, params: { email: user.email, password: "password123" }
    end
    assert_equal 1, tracked.size
    assert_equal "host_logged_in", tracked.first[0]
    assert_equal user.id,          tracked.first[1][:user_id]
  end

  test "POST /host/login does not track on failed sign-in" do
    tracked = []
    AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
      post host_login_path, params: { email: "host@example.com", password: "wrongpassword" }
    end
    assert_empty tracked
  end
end
