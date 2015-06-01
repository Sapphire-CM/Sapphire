require 'timecop'

module TimecopHelpers
  def freeze_time
    let!(:now) { Time.now }

    before(:each) do
      Timecop.freeze(now)
    end

    after(:all) do
      Timecop.return
    end
  end
end

RSpec.configure do |config|
  config.extend TimecopHelpers
end
