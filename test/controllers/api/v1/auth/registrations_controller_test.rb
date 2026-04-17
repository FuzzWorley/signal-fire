require "test_helper"

class Api::V1::Auth::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "POST /api/v1/auth/sign_up creates user and returns JWT" do
    post api_v1_auth_sign_up_path, params: {
      email: "newuser@example.com",
      password: "securepassword",
      name: "New User"
    }, as: :json

    assert_response :created
    body = response.parsed_body
    assert body["token"].present?
    assert_equal "newuser@example.com", body.dig("user", "email")
    assert User.exists?(email: "newuser@example.com")
  end

  test "POST /api/v1/auth/sign_up downcases email" do
    post api_v1_auth_sign_up_path, params: {
      email: "NEWUSER@EXAMPLE.COM",
      password: "securepassword",
      name: "New User"
    }, as: :json

    assert_response :created
    assert User.exists?(email: "newuser@example.com")
  end

  test "POST /api/v1/auth/sign_up returns 422 for duplicate email" do
    post api_v1_auth_sign_up_path, params: {
      email: "host@example.com",
      password: "securepassword",
      name: "Duplicate"
    }, as: :json

    assert_response :unprocessable_entity
    assert response.parsed_body["error"].present?
  end

  test "POST /api/v1/auth/sign_up returns 422 for short password" do
    post api_v1_auth_sign_up_path, params: {
      email: "fresh@example.com",
      password: "short",
      name: "New User"
    }, as: :json

    assert_response :unprocessable_entity
  end

  test "POST /api/v1/auth/sign_up returns 422 without email" do
    post api_v1_auth_sign_up_path, params: {
      password: "securepassword",
      name: "No Email"
    }, as: :json

    assert_response :unprocessable_entity
  end
end
