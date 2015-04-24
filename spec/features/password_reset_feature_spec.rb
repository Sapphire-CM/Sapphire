require 'rails_helper'

RSpec.describe 'Password Reset Feature' do
  it 'work with valid email' do
    account = FactoryGirl.create :account

    visit new_account_password_path
    fill_in 'Email', with: account.email
    click_on 'Reset'

    expect(page).to have_content('You will receive an email with instructions on how to reset your password in a few minutes.')
  end

  it 'does not work with invalid email' do
    visit new_account_password_path
    fill_in 'Email', with: 'foo@example'
    click_on 'Reset'

    expect(page).to have_content('not found')
  end
end
