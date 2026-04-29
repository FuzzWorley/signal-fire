module ApplicationHelper
  def app_nudges_enabled?
    ENV["APP_NUDGES_ENABLED"] == "true"
  end
end
