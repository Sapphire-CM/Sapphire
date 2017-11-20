require 'rails_helper'

RSpec.describe 'Term Editing' do
  let(:account) { term_registration.account }
  let(:term_registration) { FactoryGirl.create(:term_registration, :lecturer) }
  let(:term) { term_registration.term }

  before :each do
    sign_in account
  end

  scenario 'Navigating to the term edit page' do
    visit term_path(term)

    click_side_nav_link("Administrate")

    expect(page).to have_current_path(edit_term_path(term))
  end

  scenario 'Updating a term' do
    visit edit_term_path(term)

    fill_in "Title", with: "My fancy Term"
    fill_in "Description", with: "This term is really fancy"
    click_button "Save"

    expect(page).to have_content("successfully updated")
    expect(page).to have_current_path(term_path(term))
  end

  scenario 'Removing term title' do
    visit edit_term_path(term)

    fill_in "Title", with: ""
    click_button "Save"

    expect(page).not_to have_content("successfully updated")
    expect(page).to have_content("can't be blank")
  end
end