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
end
