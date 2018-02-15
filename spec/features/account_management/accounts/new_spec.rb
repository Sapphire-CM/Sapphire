require 'rails_helper'
require 'features/account_management/behaviours/account_side_navigation_behaviour'

RSpec.feature 'Adding Accounts' do
  let(:admin_account) { FactoryGirl.create(:account, :admin) }

  before(:each) do
    sign_in admin_account
  end

  describe 'navigation' do
    scenario "Navigating to new account page from the accounts index page" do
      visit accounts_path

      click_link "New"

      expect(page).to have_current_path(new_account_path)
    end
  end

  describe 'Form' do
    scenario "Filling out the form and creating a new account" do
      visit new_account_path

      fill_in "Email", with: "new_account@student.tugraz.at"
      fill_in "Forename", with: "John"
      fill_in "Surname", with: "Doe"
      fill_in "Matriculation number", with: "12345678"

      fill_in "Password", with: "SecretPassword"
      fill_in "Password confirmation", with: "SecretPassword"

      expect do
        click_button "Save"
      end.to change(Account, :count).by(1)

      expect(page).to have_current_path(account_path(Account.last))
      expect(page).to have_content("successfully")
    end

    scenario "Not filling out the form correctly" do
      visit new_account_path

      fill_in "Email", with: "new_account@student.tugraz.at"
      fill_in "Forename", with: "John"
      fill_in "Matriculation number", with: "12345678"

      fill_in "Password", with: "SecretPassword"
      fill_in "Password confirmation", with: "SecretPassword"

      expect do
        click_button "Save"
      end.not_to change(Account, :count)
      expect(page).not_to have_content("successfully")
    end

    scenario "Trying to create an account without a password" do
      visit new_account_path

      fill_in "Email", with: "new_account@student.tugraz.at"
      fill_in "Forename", with: "John"
      fill_in "Surname", with: "Doe"
      fill_in "Matriculation number", with: "12345678"

      expect do
        click_button "Save"
      end.not_to change(Account, :count)
      expect(page).not_to have_content("successfully")
    end

    scenario 'Cancelling account creation' do
      visit new_account_path

      click_link "Cancel"

      expect(page).to have_current_path(accounts_path)
    end
  end
end