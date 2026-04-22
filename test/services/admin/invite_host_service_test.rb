require "test_helper"

class Admin::InviteHostServiceTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "creates a user with is_host and email auth" do
    assert_difference "User.count", 1 do
      Admin::InviteHostService.new(name: "New Host", email: "fresh@example.com").call
    end
    user = User.find_by!(email: "fresh@example.com")
    assert user.is_host
    assert_equal "email", user.auth_method
    assert_equal "New Host", user.name
  end

  test "creates an invited host_profile with token and expiry" do
    assert_difference "HostProfile.count", 1 do
      Admin::InviteHostService.new(name: "Token Host", email: "token@example.com").call
    end
    profile = User.find_by!(email: "token@example.com").host_profile
    assert_equal "invited", profile.invite_status
    assert_equal "Token Host", profile.display_name
    assert profile.invitation_token.present?
    assert profile.invited_at.present?
    assert profile.invitation_token_expires_at > Time.current
  end

  test "invitation token expires 7 days from now" do
    Admin::InviteHostService.new(name: "Expiry Host", email: "expiry@example.com").call
    profile = User.find_by!(email: "expiry@example.com").host_profile
    assert_in_delta 7.days.from_now.to_i, profile.invitation_token_expires_at.to_i, 5
  end

  test "enqueues invite email" do
    assert_emails 1 do
      Admin::InviteHostService.new(name: "Email Host", email: "invite@example.com").call
    end
  end

  test "strips and downcases email" do
    Admin::InviteHostService.new(name: "Cased Host", email: "  UPPER@Example.COM  ").call
    assert User.exists?(email: "upper@example.com")
  end

  test "raises and rolls back on duplicate email" do
    existing_email = users(:host_user).email
    assert_no_difference ["User.count", "HostProfile.count"] do
      assert_raises ActiveRecord::RecordInvalid do
        Admin::InviteHostService.new(name: "Dupe", email: existing_email).call
      end
    end
  end

  test "raises and rolls back on blank name" do
    assert_no_difference "User.count" do
      assert_raises ActiveRecord::RecordInvalid do
        Admin::InviteHostService.new(name: "", email: "blank@example.com").call
      end
    end
  end
end
