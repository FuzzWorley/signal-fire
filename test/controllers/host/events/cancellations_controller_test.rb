require "test_helper"

class Host::Events::CancellationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = users(:host_user)
    post host_login_path, params: { email: @host.email, password: "password123" }
  end

  test "PATCH cancel sets status to cancelled for one-time event" do
    event = events(:upcoming_event)
    patch cancel_host_event_path(event)
    assert_redirected_to host_events_path
    assert_equal "cancelled", event.reload.status
  end

  test "PATCH cancel rejects weekly events" do
    event = events(:weekly_event)
    patch cancel_host_event_path(event)
    assert_redirected_to host_events_path
    assert flash[:alert].present?
    assert_equal "active", event.reload.status
  end

  test "PATCH cancel is unauthorized for unauthenticated user" do
    delete host_logout_path
    event = events(:upcoming_event)
    patch cancel_host_event_path(event)
    assert_redirected_to host_login_path
  end
end
