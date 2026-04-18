require "test_helper"

class PushNotificationServiceTest < ActiveSupport::TestCase
  FakeHTTP = Module.new do
    def self.post(_uri, _body, _headers)
      Struct.new(:body).new({ "data" => { "status" => "ok" } }.to_json)
    end
  end

  ErrorHTTP = Module.new do
    def self.post(_uri, _body, _headers)
      Struct.new(:body).new({
        "data" => { "status" => "error", "details" => { "error" => "DeviceNotRegistered" } }
      }.to_json)
    end
  end

  RaisingHTTP = Module.new do
    def self.post(_uri, _body, _headers)
      raise SocketError, "connection refused"
    end
  end

  test "returns error result when token is blank" do
    result = PushNotificationService.deliver(push_token: "", title: "Hi", body: "Test")
    assert_not result.ok
    assert_equal "blank token", result.error
  end

  test "returns error result when token is nil" do
    result = PushNotificationService.deliver(push_token: nil, title: "Hi", body: "Test")
    assert_not result.ok
    assert_equal "blank token", result.error
  end

  test "returns ok result on Expo success response" do
    result = PushNotificationService.deliver(
      push_token: "ExponentPushToken[abc]",
      title: "Hi",
      body: "Test",
      http_client: FakeHTTP
    )
    assert result.ok
    assert_nil result.error
  end

  test "returns error result on Expo error response" do
    result = PushNotificationService.deliver(
      push_token: "ExponentPushToken[bad]",
      title: "Hi",
      body: "Test",
      http_client: ErrorHTTP
    )
    assert_not result.ok
    assert_equal "DeviceNotRegistered", result.error
  end

  test "returns error result on network failure" do
    result = PushNotificationService.deliver(
      push_token: "ExponentPushToken[abc]",
      title: "Hi",
      body: "Test",
      http_client: RaisingHTTP
    )
    assert_not result.ok
    assert_match "connection refused", result.error
  end
end
