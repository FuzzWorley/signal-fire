class EventCancellationNotificationJob < ApplicationJob
  include EventNotificationFanout

  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event&.cancelled? && event.one_time?

    cancellation_recipients_for(event).each do |recipient|
      deliver_to(
        user: recipient[:user],
        event: event,
        notification_type: :cancelled,
        source_type: recipient[:source_type],
        title: "Event cancelled: #{event.title}",
        body: "#{event.title} at #{event.totem.name} has been cancelled."
      )
    end
  end
end
