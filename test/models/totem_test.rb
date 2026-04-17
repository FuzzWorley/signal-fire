require "test_helper"

class TotemTest < ActiveSupport::TestCase
  test "valid totem with name and slug" do
    totem = Totem.new(name: "My Totem", slug: "my-totem")
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
end
