require "test_helper"

class Api::V1::Auth::GoogleControllerTest < ActionDispatch::IntegrationTest
  MOBILE_CLIENT_ID = "test_mobile_client_id"

  setup do
    ENV["GOOGLE_CLIENT_ID_MOBILE"] = MOBILE_CLIENT_ID
  end

  def stub_http_response(response_obj)
    original = Net::HTTP.singleton_method(:get_response)
    Net::HTTP.define_singleton_method(:get_response) { |*_| response_obj }
    yield
  ensure
    Net::HTTP.define_singleton_method(:get_response, original)
  end

  def with_valid_google_token(uid:, email:, name:, &block)
    payload = { "sub" => uid, "email" => email, "name" => name, "aud" => MOBILE_CLIENT_ID }
    mock = Net::HTTPOK.new("1.1", 200, "OK")
    mock.define_singleton_method(:body) { payload.to_json }
    stub_http_response(mock, &block)
  end

  def with_invalid_google_token(&block)
    mock = Net::HTTPUnauthorized.new("1.1", 401, "Unauthorized")
    stub_http_response(mock, &block)
  end

  test "POST /api/v1/auth/google returns 400 when id_token is missing" do
    post api_v1_auth_google_path, params: {}, as: :json
    assert_response :bad_request
    assert response.parsed_body["error"].present?
  end

  test "POST /api/v1/auth/google returns 401 for invalid token" do
    with_invalid_google_token do
      post api_v1_auth_google_path, params: { id_token: "bad_token" }, as: :json
    end
    assert_response :unauthorized
  end

  test "POST /api/v1/auth/google returns 401 when aud does not match" do
    payload = { "sub" => "uid", "email" => "x@example.com", "name" => "X", "aud" => "wrong_client" }
    mock = Net::HTTPOK.new("1.1", 200, "OK")
    mock.define_singleton_method(:body) { payload.to_json }
    stub_http_response(mock) do
      post api_v1_auth_google_path, params: { id_token: "token" }, as: :json
    end
    assert_response :unauthorized
  end

  test "POST /api/v1/auth/google signs in existing user by google_uid" do
    user = users(:google_user)
    with_valid_google_token(uid: user.google_uid, email: user.email, name: user.name) do
      post api_v1_auth_google_path, params: { id_token: "token" }, as: :json
    end

    assert_response :success
    body = response.parsed_body
    assert body["token"].present?
    assert_equal user.id, JwtService.decode(body["token"])[:user_id]
  end

  test "POST /api/v1/auth/google finds user by email and links google_uid" do
    user = users(:regular_user)
    with_valid_google_token(uid: "new_uid_999", email: user.email, name: user.name) do
      post api_v1_auth_google_path, params: { id_token: "token" }, as: :json
    end

    assert_response :success
    assert_equal "new_uid_999", user.reload.google_uid
  end

  test "POST /api/v1/auth/google creates new user when none found" do
    assert_difference "User.count", 1 do
      with_valid_google_token(uid: "brand_new_uid", email: "brand_new@google.com", name: "Brand New") do
        post api_v1_auth_google_path, params: { id_token: "token" }, as: :json
      end
    end

    assert_response :success
    assert User.exists?(google_uid: "brand_new_uid")
  end

  test "POST /api/v1/auth/google identifies user with correct traits" do
    user = users(:google_user)
    identified = []
    AnalyticsService.stub(:identify, ->(id, **traits) { identified << [id, traits] }) do
      with_valid_google_token(uid: user.google_uid, email: user.email, name: user.name) do
        post api_v1_auth_google_path, params: { id_token: "token" }, as: :json
      end
    end
    assert_equal 1, identified.size
    assert_equal user.id,          identified.first[0]
    assert_equal user.email,       identified.first[1][:email]
    assert_equal user.is_host,     identified.first[1][:is_host]
  end
end
