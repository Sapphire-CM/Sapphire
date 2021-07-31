require 'rails_helper'
require 'features/account_management/behaviours/account_side_navigation_behaviour'

RSpec.feature 'Account Editing' do
  let(:admin_account) { FactoryBot.create(:account, :admin) }
  let!(:student_account) { FactoryBot.create(:account, :student, forename: 'Sam', surname: 'Secret') }
  let(:term) { student_account.term_registrations.first.term }

  before(:each) do
    sign_in admin_account
  end

  describe 'behaviours' do
    let(:base_path) { edit_account_path(student_account) }
    let(:account) { student_account }

    it_behaves_like "Account Side Navigation"
  end

  scenario 'Navigating to edit page via account path' do
    visit account_path(student_account)

    click_side_nav_link 'Edit Account'

    expect(page).to have_current_path(edit_account_path(student_account))
  end

  scenario 'Navigating to own account page' do
    visit root_path

    click_top_bar_link "Edit Account"

    expect(page).to have_current_path(edit_account_path(admin_account))
  end

  scenario 'Showing different title depending if own account is edited' do
    visit edit_account_path(student_account)
    expect(page).to have_content("Edit #{student_account.fullname}'s account")

    visit edit_account_path(admin_account)
    expect(page).to have_content("Edit your account")
  end

  scenario 'Editing account data' do
    visit edit_account_path(student_account)

    fill_in 'Forename', with: 'Pam'
    fill_in 'Surname', with: 'Supersecret'
    fill_in 'Matriculation number', with: "1337331"

    click_button 'Save'

    expect(page).to have_content("successfully updated")

    student_account.reload
    expect(student_account.forename).to eq('Pam')
    expect(student_account.surname).to eq('Supersecret')
    expect(student_account.matriculation_number).to eq('1337331')
  end

  scenario 'editing account password' do
    visit edit_account_path(student_account)

    fill_in 'Current password', with: 'secret'
    fill_in 'Password', with: 'supersecret'
    fill_in 'Password confirmation', with: 'supersecret'

    click_button 'Save'
    expect(page).not_to have_css('.input.error')

    sign_out
    sign_in_with(student_account.email, 'supersecret')

    expect(page).to have_current_path(root_path)
    expect(page).to have_content('Courses')
  end
end