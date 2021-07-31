require 'rails_helper'

RSpec.feature 'Account Removal' do
  let(:account) { FactoryBot.create(:account, :admin) }
  let!(:student_account) { FactoryBot.create(:account, :student, forename: 'Sam', surname: 'Secret') }
  let(:term) { student_account.term_registrations.first.term }

  before(:each) do
    sign_in account
  end

  scenario 'removing account' do
    visit accounts_path

    expect do
      click_link('Delete', href: account_path(student_account))
    end.to change(Account, :count).by(-1)

    expect(page).to have_current_path(accounts_path)
    within "table.accounts" do
      expect(page).not_to have_content("Sam")
      expect(page).not_to have_content("Secret")
    end
  end
end