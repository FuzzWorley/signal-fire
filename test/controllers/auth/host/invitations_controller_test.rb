require "test_helper"

class Auth::Host::InvitationsControllerTest < ActionDispatch::IntegrationTest
  test "GET /host/accept_invite with valid token renders form" do
    get host_accept_invite_path, params: { token: "valid_invite_token_abc123" }
    assert_response :success
  end

  test "GET /host/accept_invite with missing token renders invalid_token" do
    get host_accept_invite_path
    assert_response :success
    # renders invalid_token template — no session set
    assert_nil session[:user_id]
  end

  test "GET /host/accept_invite with expired token renders invalid_token" do
    profile = host_profiles(:invited_profile)
    profile.update_columns(invitation_token_expires_at: 1.hour.ago)

    get host_accept_invite_path, params: { token: "valid_invite_token_abc123" }
    assert_nil session[:user_id]
  ensure
    profile.update_columns(invitation_token_expires_at: 2.days.from_now)
  end

  test "GET /host/accept_invite with unknown token renders invalid_token" do
    get host_accept_invite_path, params: { token: "unknown_token" }
    assert_nil session[:user_id]
  end

  test "PATCH /host/accept_invite with valid token and matching passwords activates host" do
    patch host_accept_invite_path, params: {
      token: "valid_invite_token_abc123",
      password: "newpassword1",
      password_confirmation: "newpassword1"
    }
    profile = host_profiles(:invited_profile).reload
    assert_equal "active", profile.invite_status
    assert_nil profile.invitation_token
    assert_not_nil profile.invite_accepted_at
    assert_equal users(:invited_host_user).id, session[:user_id]
  end

  test "PATCH /host/accept_invite rejects blank password" do
    patch host_accept_invite_path, params: {
      token: "valid_invite_token_abc123",
      password: "",
      password_confirmation: ""
    }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_equal "invited", host_profiles(:invited_profile).reload.invite_status
  end

  test "PATCH /host/accept_invite rejects mismatched passwords" do
    patch host_accept_invite_path, params: {
      token: "valid_invite_token_abc123",
      password: "newpassword1",
      password_confirmation: "different123"
    }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "PATCH /host/accept_invite rejects password shorter than 8 characters" do
    patch host_accept_invite_path, params: {
      token: "valid_invite_token_abc123",
      password: "short",
      password_confirmation: "short"
    }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "PATCH /host/accept_invite with expired token does not activate host" do
    profile = host_profiles(:invited_profile)
    profile.update_columns(invitation_token_expires_at: 1.hour.ago)

    patch host_accept_invite_path, params: {
      token: "valid_invite_token_abc123",
      password: "newpassword1",
      password_confirmation: "newpassword1"
    }
    assert_nil session[:user_id]
    assert_equal "invited", profile.reload.invite_status
  ensure
    profile.update_columns(invitation_token_expires_at: 2.days.from_now)
  end
end
