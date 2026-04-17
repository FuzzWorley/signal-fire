require "test_helper"

class UserTest < ActiveSupport::TestCase
  # email auth validations
  test "valid email auth user" do
    user = User.new(email: "new@example.com", password: "password123", name: "New", auth_method: :email)
    assert user.valid?
  end

  test "email auth requires email" do
    user = User.new(password: "password123", name: "New", auth_method: :email)
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "email auth requires valid email format" do
    user = User.new(email: "not-an-email", password: "password123", name: "New", auth_method: :email)
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "email auth requires unique email" do
    user = User.new(email: users(:host_user).email, password: "password123", name: "New", auth_method: :email)
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "email is downcased before save" do
    user = User.create!(email: "UPPER@EXAMPLE.COM", password: "password123", name: "U", auth_method: :email)
    assert_equal "upper@example.com", user.email
  end

  test "password must be at least 8 characters" do
    user = User.new(email: "new@example.com", password: "short", name: "New", auth_method: :email)
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "password validation skipped for google users" do
    user = User.new(google_uid: "uid_xyz", email: "g@example.com", name: "G", auth_method: :google)
    assert user.valid?
  end

  test "google uid must be unique" do
    user = User.new(google_uid: users(:google_user).google_uid, name: "Dup", auth_method: :google)
    assert_not user.valid?
    assert user.errors[:google_uid].any?
  end

  test "google user without email is valid" do
    user = User.new(google_uid: "unique_uid_999", name: "No Email", auth_method: :google)
    assert user.valid?
  end

  test "email_auth? returns true for email auth method" do
    assert users(:host_user).email_auth?
  end

  test "email_auth? returns false for google auth method" do
    assert_not users(:google_user).email_auth?
  end

  test "authenticate returns user with correct password" do
    user = users(:host_user)
    assert user.authenticate("password123")
  end

  test "authenticate returns false with wrong password" do
    user = users(:host_user)
    assert_not user.authenticate("wrongpassword")
  end
end
