module FeatureHelpers
  def ensure_logged_out!
    unless @account.nil?
      visit destroy_account_session_path
      @account = nil
    end
  end

  def sign_in(account = create(:account))
    ensure_logged_out!

    visit new_account_session_path
    fill_in 'Email', with: account.email
    fill_in 'Password', with: account.password
    click_on 'Sign in'

    @account = account
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
