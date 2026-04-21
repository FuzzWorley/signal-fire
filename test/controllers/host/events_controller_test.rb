require "test_helper"

class Host::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = users(:host_user)
    @totem = totems(:main_totem)
    @event = events(:upcoming_event)
    @co_host_event = events(:co_host_event)
    post host_login_path, params: { email: @host.email, password: "password123" }
  end

  test "GET /host/events lists own and co-host events for the totem" do
    get host_events_path
    assert_response :success
    assert_select "h1", text: /events/i
  end

  test "GET /host/events/new renders form" do
    get new_host_event_path
    assert_response :success
    assert_select "form"
  end

  test "GET /host/events/:id shows read-only view for co-host event" do
    get host_event_path(@co_host_event)
    assert_response :success
    assert_select "h1", text: /co-host event/i
  end

  test "GET /host/events/:id/edit is blocked for co-host events" do
    get edit_host_event_path(@co_host_event)
    assert_response :not_found
  end

  test "POST /host/events creates a one-time event and redirects" do
    date = 2.days.from_now.to_date
    assert_difference "Event.count", 1 do
      post host_events_path, params: {
        event: {
          title: "New Test Run",
          totem_id: @totem.id,
          recurrence_type: "one_time",
          start_date: date.iso8601,
          start_time_of_day: "07:00",
          end_time_of_day: "09:00",
          chat_platform: "whatsapp",
          chat_url: "https://chat.whatsapp.com/newtest123"
        }
      }
    end
    assert_redirected_to host_events_path
    assert flash[:notice].present?
  end

  test "POST /host/events creates a weekly event and redirects" do
    assert_difference "Event.count", 1 do
      post host_events_path, params: {
        event: {
          title: "Weekly Run",
          totem_id: @totem.id,
          recurrence_type: "weekly",
          start_day_of_week: "0",
          start_time_of_day: "07:00",
          end_time_of_day: "09:00",
          chat_platform: "whatsapp",
          chat_url: "https://chat.whatsapp.com/weeklytest456"
        }
      }
    end
    assert_redirected_to host_events_path
  end

  test "POST /host/events with invalid chat URL shows errors" do
    assert_no_difference "Event.count" do
      post host_events_path, params: {
        event: {
          title: "Bad URL Run",
          totem_id: @totem.id,
          recurrence_type: "one_time",
          start_date: 2.days.from_now.to_date.iso8601,
          start_time_of_day: "07:00",
          end_time_of_day: "09:00",
          chat_platform: "whatsapp",
          chat_url: "https://discord.gg/wrong-platform"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "GET /host/events/:id/edit renders form for own event" do
    get edit_host_event_path(@event)
    assert_response :success
    assert_select "form"
  end

  test "PATCH /host/events/:id updates own event title" do
    patch host_event_path(@event), params: {
      event: { title: "Updated Title" }
    }
    assert_redirected_to host_events_path
    assert_equal "Updated Title", @event.reload.title
  end

  test "PATCH /host/events/:id is blocked for co-host events" do
    patch host_event_path(@co_host_event), params: {
      event: { title: "Hijacked Title" }
    }
    assert_response :not_found
    assert_not_equal "Hijacked Title", @co_host_event.reload.title
  end

  test "DELETE /host/events/:id destroys own event" do
    assert_difference "Event.count", -1 do
      delete host_event_path(@event)
    end
    assert_redirected_to host_events_path
  end

  test "DELETE /host/events/:id is blocked for co-host events" do
    assert_no_difference "Event.count" do
      delete host_event_path(@co_host_event)
    end
    assert_response :not_found
  end
end
