require "test_helper"

class Host::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = users(:host_user)
    @totem = totems(:main_totem)
    @event = events(:upcoming_event)
    post host_login_path, params: { email: @host.email, password: "password123" }
  end

  test "GET /host/events lists events" do
    get host_events_path
    assert_response :success
    assert_select "h1", text: /events/i
  end

  test "GET /host/events/new renders form" do
    get new_host_event_path
    assert_response :success
    assert_select "form"
  end

  test "POST /host/events creates event and redirects" do
    assert_difference "Event.count", 1 do
      post host_events_path, params: {
        event: {
          title: "New Test Run",
          totem_id: @totem.id,
          recurrence_type: "one_time",
          start_time: 2.days.from_now.change(hour: 7),
          end_time: 2.days.from_now.change(hour: 9),
          chat_platform: "whatsapp",
          chat_url: "https://chat.whatsapp.com/newtest123"
        }
      }
    end
    assert_redirected_to host_events_path
    assert flash[:notice].present?
  end

  test "POST /host/events with invalid URL shows errors" do
    assert_no_difference "Event.count" do
      post host_events_path, params: {
        event: {
          title: "Bad URL Run",
          totem_id: @totem.id,
          recurrence_type: "one_time",
          start_time: 2.days.from_now.change(hour: 7),
          end_time: 2.days.from_now.change(hour: 9),
          chat_platform: "whatsapp",
          chat_url: "https://discord.gg/wrong-platform"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "GET /host/events/:id/edit renders form" do
    get edit_host_event_path(@event)
    assert_response :success
    assert_select "form"
  end

  test "PATCH /host/events/:id updates event" do
    patch host_event_path(@event), params: {
      event: { title: "Updated Title" }
    }
    assert_redirected_to host_events_path
    assert_equal "Updated Title", @event.reload.title
  end

  test "DELETE /host/events/:id destroys event" do
    assert_difference "Event.count", -1 do
      delete host_event_path(@event)
    end
    assert_redirected_to host_events_path
  end

  test "cannot edit event belonging to another host" do
    other_host = users(:admin_user)
    other_event = events(:upcoming_event)
    other_event.update_column(:host_user_id, other_host.id)

    get edit_host_event_path(other_event)
    assert_response :not_found
  end
end
