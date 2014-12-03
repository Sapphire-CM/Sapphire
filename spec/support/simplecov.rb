require 'simplecov'

SimpleCov.start 'rails' do
  add_group "Policies", "app/policies"
  add_group "Decorators", "app/decorators"
  add_group "Uploaders", "app/uploaders"
end

SimpleCov.command_name 'RSpec'
