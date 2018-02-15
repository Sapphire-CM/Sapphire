if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.command_name 'RSpec'

  SimpleCov.start 'rails' do
    add_group "Finders", "app/finders"
    add_group "Policies", "app/policies"
    add_group "Uploaders", "app/uploaders"
    add_group "Services", "app/services"
  end
end