class PagesController < ApplicationController
  def about
  end

  def host_inquiry
    AnalyticsService.track("host_inquiry_viewed")
  end
end
