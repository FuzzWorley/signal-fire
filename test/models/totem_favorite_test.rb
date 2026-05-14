require "test_helper"

class TotemFavoriteTest < ActiveSupport::TestCase
  def build_favorite(overrides = {})
    TotemFavorite.new({
      user: users(:regular_user),
      totem: totems(:main_totem)
    }.merge(overrides))
  end

  test "valid totem favorite" do
    assert build_favorite.valid?
  end

  test "duplicate user + totem is invalid" do
    TotemFavorite.create!(user: users(:regular_user), totem: totems(:main_totem))
    duplicate = build_favorite
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end

  test "same user can favorite different totems" do
    TotemFavorite.create!(user: users(:regular_user), totem: totems(:main_totem))
    other = build_favorite(totem: totems(:secondary_totem))
    assert other.valid?
  end

  test "different users can favorite the same totem" do
    TotemFavorite.create!(user: users(:regular_user), totem: totems(:main_totem))
    other = build_favorite(user: users(:google_user))
    assert other.valid?
  end
end
