require 'rails_helper'
require 'features/account_management/behaviours/account_side_navigation_behaviour'

RSpec.shared_examples "Account Side Navigation" do
  scenario "Presents account side navigation link" do
    visit base_path

    within ".side-nav" do
      expect(page).to have_link("Overview", href: account_path(account))
      expect(page).to have_link("Edit Account", href: edit_account_path(account))
      expect(page).to have_link("Email addresses", href: account_email_addresses_path(account))
    end
  end
end