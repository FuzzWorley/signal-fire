require "test_helper"

class TotemFavoritesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user  = users(:regular_user)
    @totem = totems(:secondary_totem)
    sign_in(@user)
  end

  # ── Auth guard ────────────────────────────────────────────────────────────

  test "POST /totem_favorites redirects to sign in when not signed in" do
    delete sign_out_path
    post totem_favorites_path, params: { totem_id: @totem.id }, as: :json
    assert_redirected_to sign_in_path
  end

  test "DELETE /totem_favorites/:id redirects to sign in when not signed in" do
    favorite = totem_favorites(:follower_follows_main)
    delete sign_out_path
    delete totem_favorite_path(favorite), as: :json
    assert_redirected_to sign_in_path
  end

  # ── Create ────────────────────────────────────────────────────────────────

  test "POST /totem_favorites creates favorite for signed-in user" do
    assert_difference "TotemFavorite.count", 1 do
      post totem_favorites_path, params: { totem_id: @totem.id }, as: :json
    end
    assert_response :success
    assert_equal @totem.id, response.parsed_body["id"] && TotemFavorite.last.totem_id
  end

  test "POST /totem_favorites is idempotent for existing favorite" do
    existing = TotemFavorite.create!(user: @user, totem: @totem)
    assert_no_difference "TotemFavorite.count" do
      post totem_favorites_path, params: { totem_id: @totem.id }, as: :json
    end
    assert_response :success
    assert_equal existing.id, response.parsed_body["id"]
  end

  # ── Destroy ───────────────────────────────────────────────────────────────

  test "DELETE /totem_favorites/:id destroys the user's favorite" do
    favorite = TotemFavorite.create!(user: @user, totem: @totem)
    assert_difference "TotemFavorite.count", -1 do
      delete totem_favorite_path(favorite), as: :json
    end
    assert_response :no_content
  end

  test "DELETE /totem_favorites/:id returns 404 for another user's favorite" do
    other_favorite = totem_favorites(:follower_follows_main)
    assert_no_difference "TotemFavorite.count" do
      delete totem_favorite_path(other_favorite), as: :json
    end
    assert_response :not_found
  end

  private

  def sign_in(user)
    user.generate_magic_link_token!
    get verify_magic_link_path, params: { token: user.magic_link_token }
  end
end
