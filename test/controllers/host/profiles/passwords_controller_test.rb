require "test_helper"

class Host::Profiles::PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = users(:host_user)
    post host_login_path, params: { email: @host.email, password: "password123" }
  end

  test "GET /host/profile/password renders form" do
    get host_profile_password_path
    assert_response :success
    assert_select "form"
  end

  test "PATCH /host/profile/password changes password with correct current password" do
    patch host_profile_password_path, params: {
      password: {
        current_password: "password123",
        new_password: "newpassword456",
        new_password_confirmation: "newpassword456"
      }
    }
    assert_redirected_to host_profile_path
    assert @host.reload.authenticate("newpassword456")
  end

  test "PATCH /host/profile/password rejects wrong current password" do
    patch host_profile_password_path, params: {
      password: {
        current_password: "wrongpassword",
        new_password: "newpassword456",
        new_password_confirmation: "newpassword456"
      }
    }
    assert_response :unprocessable_entity
    assert_not @host.reload.authenticate("newpassword456")
  end

  test "PATCH /host/profile/password rejects mismatched confirmation" do
    patch host_profile_password_path, params: {
      password: {
        current_password: "password123",
        new_password: "newpassword456",
        new_password_confirmation: "differentpassword"
      }
    }
    assert_response :unprocessable_entity
    assert_not @host.reload.authenticate("newpassword456")
  end

  test "GET /host/profile/password redirects unauthenticated user" do
    delete host_logout_path
    get host_profile_password_path
    assert_redirected_to host_login_path
  end
end
