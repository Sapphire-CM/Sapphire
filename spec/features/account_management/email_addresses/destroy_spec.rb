require "rails_helper"

RSpec.describe "Email Address Removal" do
  let(:account) { FactoryBot.create(:account, :admin) }
  let(:student_account) { FactoryBot.create(:account) }
  let!(:email_address) { FactoryBot.create(:email_address, account: student_account) }

  before :each do
    sign_in account
  end

  scenario "Removing email addresses" do
    visit account_email_addresses_path(student_account)

    within "table.email-addresses" do
      click_link href: account_email_address_path(student_account, email_address)
    end

    expect(page).to have_current_path(account_email_addresses_path(student_account))
    expect(page).to have_content("Successfully removed")
    expect(page).to have_content("No additional email addresses specified.")
  end
end