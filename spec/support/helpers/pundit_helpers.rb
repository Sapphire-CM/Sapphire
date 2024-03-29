# alternative pundit & rspec integration
# http://thunderboltlabs.com/blog/2013/03/27/testing-pundit-policies-with-rspec/

RSpec::Matchers.define :permit_authorization do |action|
  match do |policy|
    policy.public_send("#{action}?")
  end

  failure_message do |policy|
    "#{policy.class} does not permit_authorization #{action} on #{policy.record} for #{policy.user.inspect}."
  end

  failure_message_when_negated do |policy|
    "#{policy.class} does not forbid #{action} on #{policy.record} for #{policy.user.inspect}."
  end
end
