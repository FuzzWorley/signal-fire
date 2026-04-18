module EventNotificationFanout
  # Returns an array of { user:, source_type: } hashes, deduplicated.
  # Users qualifying via both host_subscription and totem_follow get one entry
  # attributed to host_subscription (more specific).
  def recipients_for(event)
    by_host_sub = User
      .joins(:host_subscriptions)
      .where(host_subscriptions: { host_user_id: event.host_user_id, notify_new_event: true })
      .distinct
      .index_by(&:id)

    by_totem_follow = User
      .joins(:totem_follows)
      .where(totem_follows: { totem_id: event.totem_id, notify_new_event: true })
      .distinct
      .index_by(&:id)

    all_ids = (by_host_sub.keys + by_totem_follow.keys).uniq
    all_ids.map do |user_id|
      source = by_host_sub.key?(user_id) ? :host_subscription : :totem_follow
      { user: by_host_sub[user_id] || by_totem_follow[user_id], source_type: source }
    end
  end

  def reminder_recipients_for(event)
    by_host_sub = User
      .joins(:host_subscriptions)
      .where(host_subscriptions: { host_user_id: event.host_user_id, notify_reminder: true })
      .distinct
      .index_by(&:id)

    by_totem_follow = User
      .joins(:totem_follows)
      .where(totem_follows: { totem_id: event.totem_id, notify_reminder: true })
      .distinct
      .index_by(&:id)

    all_ids = (by_host_sub.keys + by_totem_follow.keys).uniq
    all_ids.map do |user_id|
      source = by_host_sub.key?(user_id) ? :host_subscription : :totem_follow
      { user: by_host_sub[user_id] || by_totem_follow[user_id], source_type: source }
    end
  end

  def cancellation_recipients_for(event)
    by_host_sub = User
      .joins(:host_subscriptions)
      .where(host_subscriptions: { host_user_id: event.host_user_id })
      .distinct
      .index_by(&:id)

    by_totem_follow = User
      .joins(:totem_follows)
      .where(totem_follows: { totem_id: event.totem_id })
      .distinct
      .index_by(&:id)

    all_ids = (by_host_sub.keys + by_totem_follow.keys).uniq
    all_ids.map do |user_id|
      source = by_host_sub.key?(user_id) ? :host_subscription : :totem_follow
      { user: by_host_sub[user_id] || by_totem_follow[user_id], source_type: source }
    end
  end

  def deliver_to(user:, event:, notification_type:, source_type:, title:, body:)
    return if NotificationDelivery.exists?(
      user_id: user.id,
      event_id: event.id,
      notification_type: notification_type
    )

    delivery = NotificationDelivery.create!(
      user: user,
      event: event,
      notification_type: notification_type,
      source_type: source_type,
      sent_at: Time.current
    )

    return unless user.push_token.present?

    result = PushNotificationService.deliver(
      push_token: user.push_token,
      title: title,
      body: body,
      data: { event_id: event.id, notification_type: notification_type }
    )

    AnalyticsService.track(
      "notification_sent",
      user_id: user.id,
      event_id: event.id,
      type: notification_type,
      source_type: source_type
    )

    delivery
  end
end
