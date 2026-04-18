class PreEventReminderJob < ApplicationJob
  include EventNotificationFanout

  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event&.active?

    reminder_recipients_for(event).each do |recipient|
      deliver_to(
        user: recipient[:user],
        event: event,
        notification_type: :reminder,
        source_type: recipient[:source_type],
        title: "Starting soon: #{event.title}",
        body: "#{event.title} starts in about 1 hour at #{event.totem.name}"
      )
    end

    # Chain the next reminder for weekly events
    schedule_next_reminder(event) if event.weekly?
  end

  private

  def schedule_next_reminder(event)
    next_occurrence = event.next_occurrence
    fire_at = next_occurrence + 1.week - 1.hour
    PreEventReminderJob.set(wait_until: fire_at).perform_later(event.id)
  end
end
