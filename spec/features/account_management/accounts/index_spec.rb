require 'rails_helper'

RSpec.feature 'Account List' do
  let(:account) { FactoryBot.create(:account, :admin) }

  before(:each) do
    sign_in account
  end

  scenario 'navigating to the accounts list' do
    visit root_path

    click_top_bar_link 'Accounts'

    expect(page).to have_content('Listing all accounts')
  end

  scenario 'searching for a student' do
    FactoryBot.create(:account) # push account into another table row
    FactoryBot.create(:account, forename: 'Sam', surname: 'Secret', matriculation_number: '1337331')

    visit accounts_path

    within "table tbody tr:nth-child(1)" do
      expect(page).not_to have_content('Sam')
      expect(page).not_to have_content('Secret')
    end

    fill_in 'q', with: 'sam secret'
    click_button 'search!'

    within "table tbody tr:nth-child(1)" do
      expect(page).to have_content('Sam')
      expect(page).to have_content('Secret')
      expect(page).to have_content('1337331')
    end
  end
end