require "test_helper"

class HostFollowTest < ActiveSupport::TestCase
  def build_follow(overrides = {})
    HostFollow.new({
      user: users(:regular_user),
      host_user: users(:host_user)
    }.merge(overrides))
  end

  test "valid host follow" do
    assert build_follow.valid?
  end

  test "duplicate user + host_user is invalid" do
    HostFollow.create!(user: users(:regular_user), host_user: users(:host_user))
    duplicate = build_follow
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end

  test "same user can follow different hosts" do
    HostFollow.create!(user: users(:regular_user), host_user: users(:host_user))
    other = build_follow(host_user: users(:deactivated_host_user))
    assert other.valid?
  end
end
