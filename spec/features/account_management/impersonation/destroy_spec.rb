require 'rails_helper'

RSpec.describe "Impersonation Creation" do
  let(:account) { FactoryGirl.create(:account, :admin) }
  let!(:student_account) { FactoryGirl.create(:account) }

  before :each do
    sign_in account
  end

  scenario 'Cancelling impersonation' do
    visit account_path(student_account)
    click_link "Impersonate"

    click_top_bar_link "Cancel Impersonation"
    within ".top-bar .right" do
      expect(page).not_to have_content(student_account.email)
      expect(page).to have_content(account.email)
    end
  end
end