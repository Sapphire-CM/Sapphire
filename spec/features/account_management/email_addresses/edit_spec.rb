require 'rails_helper'

RSpec.describe "Adding Email Addresses" do
  let(:account) { FactoryGirl.create(:account, :admin) }
  let(:student_account) { FactoryGirl.create(:account) }
  let(:new_email_address) { "example@student.tugraz.at" }
  let!(:email_address) { FactoryGirl.create(:email_address, account: student_account) }

  before :each do
    sign_in account
  end

  scenario "Navigating to email edit form" do
    visit account_email_addresses_path(student_account)

    within "table.email-addresses" do
      click_link "Edit"
    end

    expect(page).to have_current_path(edit_account_email_address_path(student_account, email_address))
  end

  scenario "Changing the email address" do
    visit edit_account_email_address_path(student_account, email_address)

    fill_in "Email", with: new_email_address
    click_button "Save"

    expect(page).to have_current_path(account_email_addresses_path(student_account))
    expect(page).to have_content("Successfully updated")
  end

  scenario "Changing email to an existing email address shows an error" do
    existing_email_address = FactoryGirl.create(:email_address)
    visit edit_account_email_address_path(student_account, email_address)

    fill_in "Email", with: existing_email_address.email
    click_button "Save"

    expect(page).to have_content("has already been taken")
  end

  scenario "Cancelling editing of email address" do
    visit edit_account_email_address_path(student_account, email_address)

    click_link "Cancel"

    expect(page).to have_current_path(account_email_addresses_path(student_account))
  end
end