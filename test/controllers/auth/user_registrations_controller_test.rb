require "test_helper"

class Auth::UserRegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "GET /sign_up renders new page" do
    get sign_up_path
    assert_response :success
    assert_select "h1", text: /Join Signal Fire/i
  end

  # --- Password flow ---

  test "POST /sign_up with password creates user and signs in immediately" do
    assert_difference "User.count", 1 do
      post sign_up_path, params: { email: "newuser@example.com", name: "New User", password: "secret123" }
    end
    assert_equal User.find_by(email: "newuser@example.com").id, session[:user_id]
  end

  test "POST /sign_up with password redirects to about page when no return_to stored" do
    post sign_up_path, params: { email: "newuser@example.com", name: "New User", password: "secret123" }
    assert_redirected_to about_path
  end

  test "POST /sign_up with password redirects back to totem board when return_to is stored" do
    totem = totems(:main_totem)
    get totem_board_path(totem.slug)  # stores return_to in session
    post sign_up_path, params: { email: "newuser@example.com", name: "New User", password: "secret123" }
    assert_redirected_to totem_board_path(totem.slug)
  end

  test "POST /sign_up with password does not enqueue email" do
    assert_no_enqueued_jobs only: ActionMailer::MailDeliveryJob do
      post sign_up_path, params: { email: "newuser@example.com", name: "New User", password: "secret123" }
    end
  end

  test "POST /sign_up with password responds with turbo stream success" do
    post sign_up_path,
      params: { email: "newuser@example.com", name: "New User", password: "secret123" },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_match "You're in!", response.body
  end

  test "POST /sign_up with password on existing email shows error" do
    existing = users(:regular_user)
    assert_no_difference "User.count" do
      post sign_up_path, params: { email: existing.email, name: "Someone", password: "secret123" }
    end
    assert_response :unprocessable_entity
  end

  test "POST /sign_up with password and blank name shows error" do
    assert_no_difference "User.count" do
      post sign_up_path, params: { email: "newuser@example.com", name: "", password: "secret123" }
    end
    assert_response :unprocessable_entity
  end

  test "POST /sign_up with password too short shows error" do
    assert_no_difference "User.count" do
      post sign_up_path, params: { email: "newuser@example.com", name: "New User", password: "short" }
    end
    assert_response :unprocessable_entity
  end

  # --- Magic link flow ---

  test "POST /sign_up without password creates user and enqueues email" do
    assert_difference "User.count", 1 do
      assert_enqueued_jobs 1, only: ActionMailer::MailDeliveryJob do
        post sign_up_path, params: { email: "newuser@example.com", name: "New User" }
      end
    end
    user = User.find_by(email: "newuser@example.com")
    assert user.magic_link_token.present?
    assert user.magic_link_token_expires_at > Time.current
  end

  test "POST /sign_up without password redirects with check-email notice" do
    post sign_up_path, params: { email: "newuser@example.com", name: "New User" }
    assert_redirected_to sign_up_path
    assert_match /check your email/i, flash[:notice]
  end

  test "POST /sign_up without password on existing email sends magic link, no new user" do
    existing = users(:regular_user)
    assert_no_difference "User.count" do
      assert_enqueued_jobs 1, only: ActionMailer::MailDeliveryJob do
        post sign_up_path, params: { email: existing.email, name: "Doesn't Matter" }
      end
    end
  end

  test "POST /sign_up without password and blank name shows error" do
    assert_no_difference "User.count" do
      post sign_up_path, params: { email: "newuser@example.com", name: "" }
    end
    assert_response :unprocessable_entity
  end

  test "POST /sign_up without password and invalid email shows error" do
    assert_no_difference "User.count" do
      post sign_up_path, params: { email: "not-an-email", name: "New User" }
    end
    assert_response :unprocessable_entity
  end

  test "POST /sign_up without password responds with turbo stream check-email success" do
    post sign_up_path,
      params: { email: "newuser@example.com", name: "New User" },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_match /check your email/i, response.body
  end

  test "POST /sign_up without password responds with turbo stream on error" do
    post sign_up_path,
      params: { email: "newuser@example.com", name: "" },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_match "account-signup-form-container", response.body
  end
end
