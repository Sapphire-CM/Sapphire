require 'rails_helper'

RSpec.describe "Impersonation Creation" do
  let(:account) { FactoryBot.create(:account, :admin) }
  let!(:student_account) { FactoryBot.create(:account) }
  let(:success_flash_message) { "You are now using Sapphire as '#{student_account.email}'" }

  before :each do
    sign_in account
  end

  scenario 'Starting impersonation from accounts list' do
    visit accounts_path

    within "table.accounts" do
      click_link "Impersonate", href: impersonation_path(account_id: student_account.id)
    end

    expect(page).to have_content(success_flash_message)
    within ".top-bar .right" do
      expect(page).to have_content(student_account.email)
      expect(page).not_to have_content(account.email)
    end
  end

  scenario 'Starting impersonation from accounts#show' do
    visit account_path(student_account)

    click_link "Impersonate", href: impersonation_path(account_id: student_account.id)

    expect(page).to have_content(success_flash_message)

    within ".top-bar .right" do
      expect(page).to have_content(student_account.email)
      expect(page).not_to have_content(account.email)
    end
  end
end