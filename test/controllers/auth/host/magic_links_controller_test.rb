require "test_helper"

class Auth::Host::MagicLinksControllerTest < ActionDispatch::IntegrationTest
  test "GET /host/magic_link renders request form" do
    get host_magic_link_path
    assert_response :success
  end

  test "GET /host/magic_link/sent renders confirmation page" do
    get host_magic_link_sent_path
    assert_response :success
  end

  test "POST /host/magic_link with active host email enqueues email and redirects" do
    assert_emails 1 do
      post host_magic_link_path, params: { email: "host@example.com" }
    end
    assert_redirected_to host_magic_link_sent_path
  end

  test "POST /host/magic_link generates magic link token with 30-minute expiry" do
    post host_magic_link_path, params: { email: "host@example.com" }
    profile = host_profiles(:active_profile).reload
    assert_not_nil profile.magic_link_token
    assert_in_delta 30.minutes.from_now.to_i, profile.magic_link_token_expires_at.to_i, 5
  end

  test "POST /host/magic_link with unknown email redirects silently (no enumeration)" do
    assert_emails 0 do
      post host_magic_link_path, params: { email: "nobody@example.com" }
    end
    assert_redirected_to host_magic_link_sent_path
  end

  test "POST /host/magic_link with deactivated host does not send email" do
    assert_emails 0 do
      post host_magic_link_path, params: { email: "deactivated@example.com" }
    end
    assert_redirected_to host_magic_link_sent_path
  end

  test "POST /host/magic_link with non-host email does not send email" do
    assert_emails 0 do
      post host_magic_link_path, params: { email: "user@example.com" }
    end
    assert_redirected_to host_magic_link_sent_path
  end

  test "GET /host/magic_link/verify with valid token signs in host and redirects to dashboard" do
    profile = host_profiles(:active_profile)
    profile.update_columns(
      magic_link_token: "valid_token_abc",
      magic_link_token_expires_at: 30.minutes.from_now
    )

    get host_magic_link_verify_path, params: { token: "valid_token_abc" }

    assert_redirected_to host_dashboard_path
    assert_equal profile.user_id, session[:user_id]
  end

  test "GET /host/magic_link/verify clears the token after use" do
    profile = host_profiles(:active_profile)
    profile.update_columns(
      magic_link_token: "valid_token_abc",
      magic_link_token_expires_at: 30.minutes.from_now
    )

    get host_magic_link_verify_path, params: { token: "valid_token_abc" }

    profile.reload
    assert_nil profile.magic_link_token
    assert_nil profile.magic_link_token_expires_at
  end

  test "GET /host/magic_link/verify with expired token redirects with alert" do
    profile = host_profiles(:active_profile)
    profile.update_columns(
      magic_link_token: "expired_token_abc",
      magic_link_token_expires_at: 1.minute.ago
    )

    get host_magic_link_verify_path, params: { token: "expired_token_abc" }

    assert_redirected_to host_magic_link_path
    assert_equal "That sign-in link has expired or is invalid. Please request a new one.", flash[:alert]
  end

  test "GET /host/magic_link/verify with unknown token redirects with alert" do
    get host_magic_link_verify_path, params: { token: "no_such_token" }

    assert_redirected_to host_magic_link_path
    assert_equal "That sign-in link has expired or is invalid. Please request a new one.", flash[:alert]
  end
end
