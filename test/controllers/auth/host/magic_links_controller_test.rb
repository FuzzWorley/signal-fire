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

  test "POST /host/magic_link generates token with 30-minute expiry" do
    post host_magic_link_path, params: { email: "host@example.com" }
    profile = host_profiles(:active_profile).reload
    assert_not_nil profile.invitation_token
    assert_in_delta 30.minutes.from_now.to_i, profile.invitation_token_expires_at.to_i, 5
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
end
