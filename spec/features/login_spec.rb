require 'rails_helper'

RSpec.describe 'Login Feature' do
  it 'shows the login-page if not logged in' do
    ensure_logged_out!

    visit new_account_session_path

    expect(page).to have_content('Sapphire Login')
  end

  it 'redirect to root_path if already signed in' do
    sign_in

    visit new_account_session_path

    expect(page.current_path).to eq(root_path)
    expect(page).to have_content('You are already signed in.')
  end

  it 'redirects to the login-page for all pages if not logged in' do
    [
      accounts_path,
      courses_path,
      tutorial_groups_path,
      new_term_path,
      new_exercise_path,
    ].each do |path|
      ensure_logged_out!
      visit path
      expect(page.current_path).to eq(new_account_session_path)
    end
  end

  it 'logs me in with correct credentials' do
    account = FactoryGirl.create :account

    visit new_account_session_path
    fill_in 'Email', with: account.email
    fill_in 'Password', with: account.password
    click_on 'Sign in'

    expect(page).to have_link(account.email)
    expect(page.current_path).not_to eq(new_account_session_path)
  end

  context 'login fails' do
    it 'with missing credentials' do
      visit new_account_session_path
      click_on 'Sign in'

      expect(page).to have_content('Invalid email or password.')
      expect(page.current_path).to eq(new_account_session_path)
    end

    it 'with missing email' do
      visit new_account_session_path
      fill_in 'Password', with: 'barbarbar'
      click_on 'Sign in'

      expect(page).to have_content('Invalid email or password.')
      expect(page.current_path).to eq(new_account_session_path)
    end

    it 'with wrong email' do
      visit new_account_session_path
      fill_in 'Email', with: 'foo@example.com'
      fill_in 'Password', with: 'barbarbar'
      click_on 'Sign in'

      expect(page).to have_content('Invalid email or password.')
      expect(page.current_path).to eq(new_account_session_path)
    end

    it 'with missing password' do
      account = FactoryGirl.create :account

      visit new_account_session_path
      fill_in 'Email', with: account.email
      click_on 'Sign in'

      expect(page).to have_content('Invalid email or password.')
      expect(page.current_path).to eq(new_account_session_path)
    end

    it 'with wrong password' do
      account = FactoryGirl.create :account

      visit new_account_session_path
      fill_in 'Email', with: account.email
      fill_in 'Password', with: 'barbarbar'
      click_on 'Sign in'

      expect(page).to have_content('Invalid email or password.')
      expect(page.current_path).to eq(new_account_session_path)
    end
  end
end
