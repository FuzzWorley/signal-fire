ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

# Minitest 6 removed minitest/mock. Add stub to Object so tests can use obj.stub(:method, callable) { }.
# class Object
#   def stub(method_name, callable, &block)
#     original = method(method_name)
#     metaclass = class << self; self; end
#     metaclass.define_method(method_name) do |*args, **kwargs, &blk|
#       callable.respond_to?(:call) ? callable.call(*args, **kwargs, &blk) : callable
#     end
#     block.call
#   ensure
#     metaclass.define_method(method_name, &original)
#   end
# end

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
