class Host::ApplicationController < ApplicationController
  layout "host"
  before_action :require_host!
end
