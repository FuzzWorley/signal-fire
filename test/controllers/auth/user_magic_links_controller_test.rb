require "test_helper"

class Auth::UserMagicLinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular_user)
    @user.generate_magic_link_token!
  end

  test "GET /magic_link/verify with valid token signs in user and redirects to about when no return_to" do
    get verify_magic_link_path, params: { token: @user.magic_link_token }
    assert_redirected_to about_path
    assert_equal @user.id, session[:user_id]
  end

  test "GET /magic_link/verify redirects back to totem board when return_to is stored" do
    totem = totems(:main_totem)
    get totem_board_path(totem.slug)  # stores return_to in session
    @user.generate_magic_link_token!
    get verify_magic_link_path, params: { token: @user.magic_link_token }
    assert_redirected_to totem_board_path(totem.slug)
  end

  test "GET /magic_link/verify with valid token consumes the token" do
    get verify_magic_link_path, params: { token: @user.magic_link_token }
    @user.reload
    assert_nil @user.magic_link_token
    assert_nil @user.magic_link_token_expires_at
  end

  test "GET /magic_link/verify with expired token redirects with alert" do
    @user.update!(magic_link_token_expires_at: 1.minute.ago)
    get verify_magic_link_path, params: { token: @user.magic_link_token }
    assert_redirected_to sign_in_path
    assert_match /expired or is invalid/i, flash[:alert]
    assert_nil session[:user_id]
  end

  test "GET /magic_link/verify with unknown token redirects with alert" do
    get verify_magic_link_path, params: { token: "bad-token" }
    assert_redirected_to sign_in_path
    assert_match /expired or is invalid/i, flash[:alert]
    assert_nil session[:user_id]
  end

  test "GET /magic_link/verify without token redirects with alert" do
    get verify_magic_link_path
    assert_redirected_to sign_in_path
  end
end
