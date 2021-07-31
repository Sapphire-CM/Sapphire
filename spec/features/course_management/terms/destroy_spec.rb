require 'rails_helper'

RSpec.describe 'Term Editing' do
  let(:account) { term_registration.account }
  let(:term_registration) { FactoryBot.create(:term_registration, :lecturer) }
  let(:term) { term_registration.term }

  before :each do
    sign_in account
  end

  scenario 'Removing a term' do
    visit edit_term_path(term)

    click_link "Delete Term"

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("successfully deleted")
  end
end