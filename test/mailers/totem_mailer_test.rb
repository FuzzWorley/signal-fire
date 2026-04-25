require "test_helper"

class TotemMailerTest < ActionMailer::TestCase
  test "capture_confirmation_email" do
    capture = empty_totem_email_captures(:fan_one)
    mail = TotemMailer.capture_confirmation_email(capture)

    assert_equal "You're on the list for #{capture.totem.name}", mail.subject
    assert_equal [ capture.email ], mail.to
    assert_match capture.totem.name, mail.body.encoded
  end
end
