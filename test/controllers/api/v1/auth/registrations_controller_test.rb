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

  test "POST /api/v1/auth/sign_up identifies user with correct traits" do
    identified = []
    AnalyticsService.stub(:identify, ->(id, **traits) { identified << [id, traits] }) do
      post api_v1_auth_sign_up_path, params: {
        email: "analytics@example.com",
        password: "securepassword",
        name: "Analytics User"
      }, as: :json
    end
    assert_equal 1, identified.size
    user = User.find_by(email: "analytics@example.com")
    assert_equal user.id,          identified.first[0]
    assert_equal user.email,       identified.first[1][:email]
    assert_equal user.auth_method, identified.first[1][:auth_method]
    assert_equal user.is_host,     identified.first[1][:is_host]
  end
end
