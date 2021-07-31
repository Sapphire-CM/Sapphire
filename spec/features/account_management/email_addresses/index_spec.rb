require 'rails_helper'

RSpec.describe "Email Addresses List" do
  before :each do
    sign_in account
  end

  shared_examples "Email Addresses List" do
    scenario 'Navigating to the email list through accounts#edit' do
      visit edit_account_path(account)

      click_side_nav_link("Email addresses")

      expect(page).to have_current_path(account_email_addresses_path(account))
    end

    scenario 'Navigating to the email list through accounts#show' do
      visit account_path(account)

      click_side_nav_link("Email addresses")

      expect(page).to have_current_path(account_email_addresses_path(account))
    end

    context 'without email addresses' do
      scenario 'Shows empty notice' do
        visit account_email_addresses_path(account)

        expect(page).to have_content("No additional email addresses specified.")
      end
    end

    context 'with email addresses' do
      let!(:email_addresses) { FactoryBot.create_list(:email_address, 3, account: account) }
      let!(:other_email_address) { FactoryBot.create(:email_address) }

      scenario "Lists email addresses associated with account" do
        visit account_email_addresses_path(account)

        email_addresses.each do |email_address|
          expect(page).to have_content(email_address.email)
        end
        expect(page).not_to have_content(other_email_address.email)
      end

      scenario "Linking to the email address" do
        visit account_email_addresses_path(account)

        expect(page).to have_link(email_addresses.first.email, href: "mailto:#{email_addresses.first.email}")
      end
    end
  end

  context "as admin" do
    let(:account) { FactoryBot.create(:account, :admin) }

    it_behaves_like "Email Addresses List"

    scenario 'Navigating to the email list through accounts#show' do
      visit account_path(account)

      click_side_nav_link("Email addresses")

      expect(page).to have_current_path(account_email_addresses_path(account))
    end

    scenario 'Presents add link' do
      visit account_email_addresses_path(account)

      expect(page).to have_link("Add", href: new_account_email_address_path(account))
    end
  end

  context "as ordinary user" do
    let(:account) { FactoryBot.create(:account) }

    it_behaves_like "Email Addresses List"

    scenario 'Does not present add link' do
      visit account_email_addresses_path(account)

      expect(page).not_to have_link("Add")
    end
  end
end