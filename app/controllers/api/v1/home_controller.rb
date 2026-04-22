class Api::V1::HomeController < Api::V1::ApplicationController
  include Api::V1::Concerns::EventSerializer

  def index
    follows = current_user.totem_follows
      .includes(totem: { events: { host_user: :host_profile } })

    boards = follows.map { |follow| build_board(follow.totem) }

    render json: { boards: boards }
  end

  private

  def build_board(totem)
    # events is already preloaded — filter in Ruby to avoid extra queries
    active_events = totem.events.select { |e| e.active? }

    now = Time.current
    window_before = now - Event::CHECKIN_WINDOW_AFTER_MINUTES.minutes
    window_after  = now + Event::CHECKIN_WINDOW_BEFORE_MINUTES.minutes

    active_now_events = active_events.select { |e|
      e.start_time <= window_after && e.end_time >= window_before
    }
    upcoming_events = (active_events - active_now_events).select { |e|
      e.next_occurrence > window_after
    }

    # Preload check-in/subscription data for this totem's events
    all_events = active_now_events + upcoming_events
    preload_user_event_data(all_events)

    active_event = active_now_events.min_by { |e|
      e.start_time <= now && e.end_time >= now ? 0 : 1
    }
    next_event = upcoming_events.min_by(&:next_occurrence)

    {
      totem_id: totem.id,
      totem_name: totem.name,
      totem_slug: totem.slug,
      totem_location: [totem.location, totem.sublocation].compact.join(" · "),
      active_event: active_event ? build_event_json(active_event) : nil,
      next_event: next_event ? build_event_json(next_event) : nil
    }
  end
end
