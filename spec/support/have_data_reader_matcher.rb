require 'securerandom'

RSpec::Matchers.define :have_data_reader do |method|
  match do |model|
    value = SecureRandom.hex

    model.data[method] = value
    model.send(method) == value
  end

  diffable
end
