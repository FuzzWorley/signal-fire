ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    include ActiveJob::TestHelper
  end
end

module ActionDispatch
  class IntegrationTest
    def auth_header(user)
      token = JwtService.encode(user_id: user.id)
      { "Authorization" => "Bearer #{token}" }
    end
  end
end
