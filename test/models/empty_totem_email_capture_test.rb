require "test_helper"

class EmptyTotemEmailCaptureTest < ActiveSupport::TestCase
  def build_capture(overrides = {})
    EmptyTotemEmailCapture.new({
      totem: totems(:main_totem),
      email: "visitor@example.com"
    }.merge(overrides))
  end

  test "captured_at is auto-set before validation" do
    capture = build_capture
    capture.valid?
    assert_not_nil capture.captured_at
  end

  test "email is required" do
    capture = build_capture(email: nil)
    assert_not capture.valid?
    assert capture.errors[:email].any?
  end

  test "email must be valid format" do
    capture = build_capture(email: "not-an-email")
    assert_not capture.valid?
    assert capture.errors[:email].any?
  end

  test "valid email capture" do
    assert build_capture.valid?
  end
end
