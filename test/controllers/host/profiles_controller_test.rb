require "test_helper"

class Host::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = users(:host_user)
    post host_login_path, params: { email: @host.email, password: "password123" }
  end

  test "GET /host/profile renders edit form" do
    get host_profile_path
    assert_response :success
    assert_select "h1", text: /profile/i
  end

  test "PATCH /host/profile updates display_name and blurb" do
    patch host_profile_path, params: {
      profile: { display_name: "New Name", blurb: "New bio" }
    }
    assert_redirected_to host_profile_path
    @host.host_profile.reload
    assert_equal "New Name", @host.host_profile.display_name
    assert_equal "New bio", @host.host_profile.blurb
  end

  test "PATCH /host/profile changes password with correct current password" do
    patch host_profile_path, params: {
      profile: {
        display_name: @host.host_profile.display_name,
        current_password: "password123",
        password: "newpassword456",
        password_confirmation: "newpassword456"
      }
    }
    assert_redirected_to host_profile_path
    assert @host.reload.authenticate("newpassword456")
  end

  test "PATCH /host/profile rejects password change with wrong current password" do
    patch host_profile_path, params: {
      profile: {
        display_name: @host.host_profile.display_name,
        current_password: "wrongpassword",
        password: "newpassword456",
        password_confirmation: "newpassword456"
      }
    }
    assert_response :unprocessable_entity
    assert_not @host.reload.authenticate("newpassword456")
  end

  test "GET /host/profile redirects unauthenticated user" do
    delete host_logout_path
    get host_profile_path
    assert_redirected_to host_login_path
  end
end
