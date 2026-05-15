class FirstStrangerNotificationJob < ApplicationJob
  queue_as :default

  def perform(check_in_id)
    check_in  = CheckIn.includes(:event, :user).find(check_in_id)
    host_user = check_in.event.host_user

    return unless host_user.push_token.present?

    return if NotificationDelivery.exists?(
      user:              host_user,
      event:             check_in.event,
      notification_type: :first_stranger
    )

    sso_token = JwtService.encode(user_id: host_user.id, exp: 1.hour.from_now.to_i)
    sso_url   = "https://host.signalfire.live/host/dashboard?sso_token=#{sso_token}"

    result = PushNotificationService.deliver(
      push_token: host_user.push_token,
      title: "Someone new just checked in",
      body:  "Someone new just checked into #{check_in.event.title}.",
      data:  { type: "first_stranger", event_id: check_in.event.id, sso_url: sso_url }
    )

    host_user.update_column(:push_token, nil) if result.error == "DeviceNotRegistered"

    NotificationDelivery.create!(
      user:              host_user,
      event:             check_in.event,
      notification_type: :first_stranger,
      source_type:       :direct,
      sent_at:           Time.current
    )

    AnalyticsService.track("first_stranger_notification_sent",
      host_user_id: host_user.id, event_id: check_in.event.id)
  end
end
