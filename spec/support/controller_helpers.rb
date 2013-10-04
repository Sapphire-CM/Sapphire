module ControllerHelpers
  def sign_in(account = create(:account))
    if account.nil?
      request.env['warden'].stub(:authenticate!).
        and_throw(:warden, {:scope => :account})
      controller.stub :current_account => nil
    else
      request.env['warden'].stub :authenticate! => account
      controller.stub :current_account => account
    end
  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.include ControllerHelpers, :type => :controller
end