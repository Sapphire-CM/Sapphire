require 'rails_helper'

RSpec.describe "Adding Email Addresses" do
  let(:account) { FactoryBot.create(:account, :admin) }
  let(:student_account) { FactoryBot.create(:account) }
  let(:new_email_address) { "example@student.tugraz.at" }

  before :each do
    sign_in account
  end

  scenario 'Navigating to new email address form' do
    visit account_email_addresses_path(student_account)

    click_link "Add"

    expect(page).to have_current_path(new_account_email_address_path(student_account))
  end

  scenario 'Adding new email address to account' do
    visit new_account_email_address_path(student_account)

    fill_in "Email", with: new_email_address

    click_button "Save"

    expect(page).to have_current_path(account_email_addresses_path(student_account))
    expect(page).to have_content("Successfully added")
    expect(page).to have_content(new_email_address)
  end

  scenario 'Shows error when filling in an existing email address' do
    existing_email_address = FactoryBot.create(:email_address)
    visit new_account_email_address_path(student_account)

    fill_in "Email", with: existing_email_address.email

    click_button "Save"

    expect(page).to have_content("has already been taken")
  end

  scenario "Cancelling adding an email links to email addresses path" do
    visit new_account_email_address_path(student_account)

    click_link "Cancel"

    expect(page).to have_current_path(account_email_addresses_path(student_account))
  end
end