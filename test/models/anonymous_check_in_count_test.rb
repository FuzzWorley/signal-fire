require "test_helper"

class AnonymousCheckInCountTest < ActiveSupport::TestCase
  def build_count(overrides = {})
    AnonymousCheckInCount.new({
      event: events(:upcoming_event),
      count: 5
    }.merge(overrides))
  end

  test "valid anonymous check-in count" do
    assert build_count.valid?
  end

  test "count of zero is valid" do
    assert build_count(count: 0).valid?
  end

  test "negative count is invalid" do
    record = build_count(count: -1)
    assert_not record.valid?
    assert record.errors[:count].any?
  end
end
