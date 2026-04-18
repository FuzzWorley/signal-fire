class NewEventNotificationJob < ApplicationJob
  include EventNotificationFanout

  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event&.active?

    recipients_for(event).each do |recipient|
      deliver_to(
        user: recipient[:user],
        event: event,
        notification_type: :new_event,
        source_type: recipient[:source_type],
        title: "New event at #{event.totem.name}",
        body: "#{event.title} — #{event.start_time.strftime("%a %b %-d at %-I:%M %p")}"
      )
    end
  end
end
