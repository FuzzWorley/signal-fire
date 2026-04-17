require "test_helper"

class HostProfileTest < ActiveSupport::TestCase
  def build_profile(overrides = {})
    HostProfile.new({
      user: users(:regular_user),
      display_name: "Test Host",
      invite_status: :invited
    }.merge(overrides))
  end

  test "valid host profile" do
    assert build_profile.valid?
  end

  test "display_name is required" do
    profile = build_profile(display_name: nil)
    assert_not profile.valid?
    assert profile.errors[:display_name].any?
  end

  test "invite_status is required" do
    profile = build_profile(invite_status: nil)
    assert_not profile.valid?
    assert profile.errors[:invite_status].any?
  end

  test "invited? returns true for invited status" do
    assert host_profiles(:invited_profile).invited?
  end

  test "active? returns true for active status" do
    assert host_profiles(:active_profile).active?
  end

  test "deactivated? returns true for deactivated status" do
    assert host_profiles(:deactivated_profile).deactivated?
  end
end
