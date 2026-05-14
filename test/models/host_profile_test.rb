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

  # slug generation
  test "slug auto-generated from display_name on save" do
    profile = build_profile(display_name: "Jane Doe")
    profile.valid?
    assert_equal "jane-doe", profile.slug
  end

  test "slug with collision appends incrementing suffix" do
    HostProfile.create!(user: users(:regular_user), display_name: "Jane Doe", invite_status: :invited)
    profile = build_profile(display_name: "Jane Doe", user: users(:google_user))
    profile.valid?
    assert_equal "jane-doe-2", profile.slug
  end

  test "slug rejects invalid characters" do
    profile = build_profile(slug: "Bad Slug!")
    assert_not profile.valid?
    assert profile.errors[:slug].any?
  end

  test "slug allows lowercase letters, numbers, and hyphens" do
    profile = build_profile(slug: "good-slug-123")
    assert profile.valid?
  end

  test "slug must be unique" do
    HostProfile.create!(user: users(:regular_user), display_name: "Jane Doe", slug: "taken-slug", invite_status: :invited)
    profile = build_profile(slug: "taken-slug", user: users(:google_user))
    assert_not profile.valid?
    assert profile.errors[:slug].any?
  end
end
