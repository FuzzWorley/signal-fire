require "test_helper"

class UserHostFirstSeenTest < ActiveSupport::TestCase
  def build_record(overrides = {})
    UserHostFirstSeen.new({
      user: users(:regular_user),
      host_user: users(:host_user),
      first_seen_at: Time.current
    }.merge(overrides))
  end

  test "valid record" do
    assert build_record.valid?
  end

  test "first_seen_at is required" do
    record = build_record(first_seen_at: nil)
    assert_not record.valid?
    assert record.errors[:first_seen_at].any?
  end

  test "duplicate user + host_user pair is invalid" do
    UserHostFirstSeen.create!(user: users(:regular_user), host_user: users(:host_user), first_seen_at: Time.current)
    duplicate = build_record
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end

  test "same user can have first_seen for different hosts" do
    UserHostFirstSeen.create!(user: users(:regular_user), host_user: users(:host_user), first_seen_at: Time.current)
    other = build_record(host_user: users(:deactivated_host_user))
    assert other.valid?
  end

  test "different users can have first_seen for the same host" do
    UserHostFirstSeen.create!(user: users(:regular_user), host_user: users(:host_user), first_seen_at: Time.current)
    other = build_record(user: users(:google_user))
    assert other.valid?
  end
end
