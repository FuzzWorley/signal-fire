require "test_helper"

class Api::V1::Auth::AppleControllerTest < ActionDispatch::IntegrationTest
  test "POST /api/v1/auth/apple returns 501 not implemented" do
    post api_v1_auth_apple_path, params: {}, as: :json
    assert_response :not_implemented
    assert response.parsed_body["error"].present?
  end
end
