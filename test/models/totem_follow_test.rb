require "test_helper"

class TotemFollowTest < ActiveSupport::TestCase
  def build_follow(overrides = {})
    TotemFollow.new({
      user: users(:regular_user),
      totem: totems(:main_totem)
    }.merge(overrides))
  end

  test "valid totem follow" do
    assert build_follow.valid?
  end

  test "duplicate user + totem is invalid" do
    TotemFollow.create!(user: users(:regular_user), totem: totems(:main_totem))
    duplicate = build_follow
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end

  test "same user can follow different totems" do
    TotemFollow.create!(user: users(:regular_user), totem: totems(:main_totem))
    other = build_follow(totem: totems(:secondary_totem))
    assert other.valid?
  end

  test "different users can follow the same totem" do
    TotemFollow.create!(user: users(:regular_user), totem: totems(:main_totem))
    other = build_follow(user: users(:google_user))
    assert other.valid?
  end
end
