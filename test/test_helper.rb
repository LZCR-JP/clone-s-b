ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def create_host(email: "host@example.com")
      User.find_by(email: email) || User.create!(name: "Host", email: email, password: "password123")
    end

    def create_nomikai(user: create_host, **attrs)
      user.nomikais.create!({ area: "Shibuya", event_date: 1.week.from_now, group_size: 4 }.merge(attrs))
    end
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
