require "test_helper"

class JwtServiceTest < ActiveSupport::TestCase
  test "encodes and decodes a payload" do
    token = JwtService.encode(user_id: 42)
    payload = JwtService.decode(token)
    assert_equal 42, payload[:user_id]
  end

  test "decoded payload includes expiry" do
    token = JwtService.encode(user_id: 1)
    payload = JwtService.decode(token)
    assert payload[:exp].present?
    assert payload[:exp] > Time.current.to_i
  end

  test "decode returns nil for tampered token" do
    token = JwtService.encode(user_id: 1)
    tampered = token[0..-5] + "XXXX"
    assert_nil JwtService.decode(tampered)
  end

  test "decode returns nil for garbage string" do
    assert_nil JwtService.decode("not.a.token")
  end

  test "decode returns nil for empty string" do
    assert_nil JwtService.decode("")
  end
end
