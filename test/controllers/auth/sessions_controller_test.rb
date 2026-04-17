require "test_helper"

class Auth::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth.delete(:google_oauth2)
  end

  def set_google_mock(uid:, email:, name:)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: { email: email, name: name }
    )
  end

  def perform_google_login(uid:, email:, name:)
    set_google_mock(uid: uid, email: email, name: name)
    get "/auth/google_oauth2"
    follow_redirect!
  end

  test "google_callback signs in existing user by google_uid" do
    user = users(:google_user)
    perform_google_login(uid: user.google_uid, email: user.email, name: user.name)
    assert_equal user.id, session[:user_id]
  end

  test "google_callback finds existing user by email and links google_uid" do
    user = users(:regular_user)
    perform_google_login(uid: "linked_uid_123", email: user.email, name: user.name)
    assert_equal user.id, session[:user_id]
    assert_equal "linked_uid_123", user.reload.google_uid
  end

  test "google_callback creates a new user when none found" do
    assert_difference "User.count", 1 do
      perform_google_login(uid: "brand_new_uid", email: "brand_new@example.com", name: "Brand New")
    end
    new_user = User.find_by(google_uid: "brand_new_uid")
    assert_equal new_user.id, session[:user_id]
  end

  test "google_callback redirects admin to admin_root" do
    user = users(:admin_user)
    user.update!(google_uid: "admin_google_uid", auth_method: :google)
    perform_google_login(uid: "admin_google_uid", email: user.email, name: user.name)
    assert_redirected_to admin_root_path
  end

  test "google_callback redirects active host to host_dashboard" do
    user = users(:host_user)
    user.update!(google_uid: "host_google_uid", auth_method: :google)
    perform_google_login(uid: "host_google_uid", email: user.email, name: user.name)
    assert_redirected_to host_dashboard_path
  end

  test "google_callback redirects regular user to root" do
    perform_google_login(uid: "new_uid_xyz", email: "newxyz@example.com", name: "New XYZ")
    assert_redirected_to root_path
  end
end
