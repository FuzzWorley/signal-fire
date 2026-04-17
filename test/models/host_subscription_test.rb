require "test_helper"

class HostSubscriptionTest < ActiveSupport::TestCase
  def build_subscription(overrides = {})
    HostSubscription.new({
      user: users(:regular_user),
      host_user: users(:host_user)
    }.merge(overrides))
  end

  test "valid host subscription" do
    assert build_subscription.valid?
  end

  test "duplicate user + host_user is invalid" do
    HostSubscription.create!(user: users(:regular_user), host_user: users(:host_user))
    duplicate = build_subscription
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end

  test "same user can subscribe to different hosts" do
    HostSubscription.create!(user: users(:regular_user), host_user: users(:host_user))
    other = build_subscription(host_user: users(:deactivated_host_user))
    assert other.valid?
  end
end
