module FeatureHelpers
  def ensure_logged_out!
    unless @current_account.nil?
      sign_out
    end
  end

  def sign_in(account = FactoryGirl.create(:account))
    ensure_logged_out!

    sign_in_with(account.email, account.password)
  end

  def sign_in_with(email, password)
    visit new_account_session_path

    fill_in 'Email', with: email
    fill_in 'Password', with: password

    click_on 'Sign in'

    @current_account = account
  end

  def sign_out
    visit destroy_account_session_path
    @current_account = nil
  end

  def click_top_bar_link(*args)
    within '.top-bar' do
      click_link *args
    end
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
