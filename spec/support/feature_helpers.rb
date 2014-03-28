module FeatureHelpers
  def sign_in(account = create(:account))
    visit '/accounts/sign_in'
    fill_in "account_email", :with => account.email
    fill_in "account_password", :with => account.password
    click_button "Sign in"
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, :type => :feature
end