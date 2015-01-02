module FeatureHelpers
  def ensure_logged_out!
    unless @current_account.nil?
      visit destroy_account_session_path
      @current_account = nil
    end
  end

  def sign_in(account = FactoryGirl.create(:account))
    ensure_logged_out!

    visit new_account_session_path
    fill_in 'Email', with: account.email
    fill_in 'Password', with: account.password
    click_on 'Sign in'

    @current_account = account
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
