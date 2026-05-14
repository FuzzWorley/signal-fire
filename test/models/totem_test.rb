require "test_helper"

class TotemTest < ActiveSupport::TestCase
  test "valid totem with name and slug" do
    totem = Totem.new(name: "My Totem", slug: "my-totem", location: "Some Park")
    assert totem.valid?
  end

  test "name is required" do
    totem = Totem.new(slug: "my-totem")
    assert_not totem.valid?
    assert totem.errors[:name].any?
  end

  test "slug is auto-generated from name" do
    totem = Totem.new(name: "My Totem")
    totem.valid?
    assert_equal "my-totem", totem.slug
  end

  test "slug must be unique" do
    totem = Totem.new(name: "Main Totem", slug: "main-totem")
    assert_not totem.valid?
    assert totem.errors[:slug].any?
  end

  test "slug collision appends incrementing suffix" do
    totem = Totem.new(name: "Main Totem")
    totem.valid?
    assert_equal "main-totem-2", totem.slug
  end

  test "slug format rejects uppercase" do
    totem = Totem.new(name: "Fine Name", slug: "BAD-SLUG")
    assert_not totem.valid?
    assert totem.errors[:slug].any?
  end

  test "slug format rejects spaces" do
    totem = Totem.new(name: "Fine Name", slug: "bad slug")
    assert_not totem.valid?
    assert totem.errors[:slug].any?
  end

  # V1.5 scopes
  test "for_city returns totems matching city_slug" do
    results = Totem.for_city("stpete")
    assert results.include?(totems(:main_totem))
  end

  test "city_board_visible returns active totems with character_description" do
    results = Totem.city_board_visible
    assert results.include?(totems(:city_board_totem))
    assert_not results.include?(totems(:main_totem))
  end

  test "city_board_visible excludes inactive totems" do
    assert_not Totem.city_board_visible.include?(totems(:inactive_totem))
  end

  # character_description validation
  test "character_description over 140 chars is invalid" do
    totem = Totem.new(name: "Test", location: "Park", character_description: "x" * 141)
    assert_not totem.valid?
    assert totem.errors[:character_description].any?
  end

  test "character_description at 140 chars is valid" do
    totem = Totem.new(name: "Test", location: "Park", character_description: "x" * 140)
    assert totem.valid?
  end
end
