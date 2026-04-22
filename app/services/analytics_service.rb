class AnalyticsService
  def self.track(event_name, user_id: nil, **properties)
    if log_only?
      Rails.logger.info("[Analytics] #{event_name} #{{ **properties, user_id: }.to_json}")
      return
    end

    PostHog.capture({
      distinct_id: user_id&.to_s || "anonymous",
      event: event_name.to_s,
      properties: properties
    })
  rescue => e
    Rails.logger.error("[Analytics] Failed to track #{event_name}: #{e.message}")
  end

  def self.identify(user_id, **traits)
    if log_only?
      Rails.logger.info("[Analytics] identify #{user_id} #{traits.to_json}")
      return
    end

    PostHog.identify({ distinct_id: user_id.to_s, properties: traits })
  rescue => e
    Rails.logger.error("[Analytics] Failed to identify #{user_id}: #{e.message}")
  end

  def self.log_only?
    Rails.env.test?
  end
  private_class_method :log_only?
end
