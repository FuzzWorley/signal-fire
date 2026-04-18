require "test_helper"

class AnalyticsServiceTest < ActiveSupport::TestCase
  test "track returns without error" do
    assert_nothing_raised do
      AnalyticsService.track("totem_board_viewed", totem_id: 1, auth_state: :anonymous)
    end
  end

  test "track accepts all §6.8 event names without error" do
    events = %w[
      totem_board_viewed event_detail_viewed chat_link_clicked
      check_in_anonymous check_in_authenticated app_install_nudge_shown
      app_store_badge_clicked host_subscribed host_unsubscribed
      totem_followed totem_unfollowed notification_sent notification_opened
      host_event_created host_logged_in host_last_activity_at
      empty_totem_email_captured
    ]
    events.each do |name|
      assert_nothing_raised { AnalyticsService.track(name, dummy: true) }
    end
  end

  test "track accepts arbitrary keyword properties" do
    assert_nothing_raised do
      AnalyticsService.track("notification_sent",
        user_id: 1, event_id: 2, type: "new_event", source_type: "host_subscription")
    end
  end
end
