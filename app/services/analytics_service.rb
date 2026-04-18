class AnalyticsService
  def self.track(event_name, **properties)
    Rails.logger.info("[Analytics] #{event_name} #{properties.to_json}")
  end
end
