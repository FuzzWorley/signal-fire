require "test_helper"

class HostMailerTest < ActionMailer::TestCase
  test "invite_email delivers to host's email address" do
    profile = host_profiles(:invited_profile)
    mail = HostMailer.invite_email(profile)
    assert_equal [ profile.user.email ], mail.to
  end

  test "invite_email has correct subject" do
    mail = HostMailer.invite_email(host_profiles(:invited_profile))
    assert_equal "You're invited to host on Signal Fire", mail.subject
  end

  test "invite_email text part contains the magic link" do
    profile = host_profiles(:invited_profile)
    mail = HostMailer.invite_email(profile)
    assert_match profile.invitation_token, mail.text_part.body.to_s
  end

  test "invite_email HTML part contains the magic link" do
    profile = host_profiles(:invited_profile)
    mail = HostMailer.invite_email(profile)
    assert_match profile.invitation_token, mail.html_part.body.to_s
  end

  test "invite_email HTML part contains host display name" do
    profile = host_profiles(:invited_profile)
    mail = HostMailer.invite_email(profile)
    assert_match profile.display_name, mail.html_part.body.to_s
  end

  test "invite_email HTML part mentions 72 hours expiry" do
    mail = HostMailer.invite_email(host_profiles(:invited_profile))
    assert_match "72 hours", mail.html_part.body.to_s
  end

  test "magic_link_email delivers to host's email address" do
    profile = host_profiles(:active_profile)
    profile.update_columns(magic_link_token: "test_magic_token_xyz")
    mail = HostMailer.magic_link_email(profile)
    assert_equal [ profile.user.email ], mail.to
  end

  test "magic_link_email has correct subject" do
    profile = host_profiles(:active_profile)
    profile.update_columns(magic_link_token: "test_magic_token_xyz")
    mail = HostMailer.magic_link_email(profile)
    assert_equal "Your Signal Fire login link", mail.subject
  end

  test "magic_link_email text part contains the magic link token" do
    profile = host_profiles(:active_profile)
    profile.update_columns(magic_link_token: "test_magic_token_xyz")
    mail = HostMailer.magic_link_email(profile)
    assert_match "test_magic_token_xyz", mail.text_part.body.to_s
  end

  test "magic_link_email HTML part contains the magic link token" do
    profile = host_profiles(:active_profile)
    profile.update_columns(magic_link_token: "test_magic_token_xyz")
    mail = HostMailer.magic_link_email(profile)
    assert_match "test_magic_token_xyz", mail.html_part.body.to_s
  end

  test "magic_link_email HTML part mentions 30 minutes expiry" do
    profile = host_profiles(:active_profile)
    profile.update_columns(magic_link_token: "test_magic_token_xyz")
    mail = HostMailer.magic_link_email(profile)
    assert_match "30 minutes", mail.html_part.body.to_s
  end
end
