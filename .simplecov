SimpleCov.start 'rails' do
  add_group "Policies", "app/policies"
  add_group "Uploaders", "app/uploaders"
  add_group "Services", "app/services"
end

puts "simplecov loaded"