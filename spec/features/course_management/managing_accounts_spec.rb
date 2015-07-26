require 'rails_helper'

RSpec.feature 'Managing Accounts' do
  let(:account) { FactoryGirl.create(:account, :admin) }

  before(:each) do
    sign_in account
  end

  scenario 'navigating to the accounts list' do
    visit root_path

    click_top_bar_link 'Accounts'

    expect(page).to have_content('Listing all accounts')
  end


  scenario 'searching for a student' do
    FactoryGirl.create(:account) # push account into another table row
    FactoryGirl.create(:account, forename: 'Sam', surname: 'Secret', matriculation_number: '1337331')

    visit accounts_path

    within "table tbody tr:nth-child(1)" do
      expect(page).not_to have_content('Sam')
      expect(page).not_to have_content('Secret')
    end


    fill_in 'q', with: 'sam secret'
    click_button 'search!'

    within "table tbody tr:nth-child(1)" do
      expect(page).to have_content('Sam')
      expect(page).to have_content('Secret')
    end
  end

  scenario 'viewing an account' do
    student = FactoryGirl.create(:account, :student, forename: 'Sam', surname: 'Secret')
    term = student.term_registrations.first.term

    visit accounts_path

    within 'table tbody tr:nth-child(2)' do
      expect(page).to have_content('Sam')
      expect(page).to have_content('Secret')

      click_link 'View'
    end

    within '#site_title' do
      expect(page).to have_content('Sam Secret')
    end

    expect(page).to have_content(term.title)
  end

  scenario 'removing account' do
    FactoryGirl.create(:account)

    visit accounts_path

    within 'table tbody tr:nth-child(1)' do
      expect(page).to have_link('Delete')

      expect do
        click_link('Delete')
      end.to change(Account, :count).by(-1)
    end
  end

  describe 'editing an account' do
    scenario 'navigating to edit page' do
      visit accounts_path

      within 'table' do
        first(:link, 'View').click
      end

      click_link 'Edit'

      expect(page.current_path).to eq(edit_account_path(account))
    end

    scenario 'editing account data' do
      student = FactoryGirl.create(:account, :student, forename: 'John', surname: 'Doe', matriculation_number: '1212121')

      visit account_path(student)

      click_link 'Edit'

      fill_in 'Forename', with: 'Sam'
      fill_in 'Surname', with: 'Secret'
      fill_in 'Matriculation number', with: "1337331"

      click_button 'Save'

      student.reload

      expect(student.forename).to eq('Sam')
      expect(student.surname).to eq('Secret')
      expect(student.matriculation_number).to eq('1337331')
    end

    scenario 'editing account password' do
      student = FactoryGirl.create(:account, :student, password: 'secret')

      visit edit_account_path(student)

      fill_in 'Current password', with: 'secret'
      fill_in 'Password', with: 'supersecret'
      fill_in 'Password confirmation', with: 'supersecret'

      click_button 'Save'
      expect(page).not_to have_css('.input.error')

      sign_out
      sign_in_with(student.email, 'supersecret')

      expect(page.current_path).to eq(root_path)
      expect(page).to have_content('Courses')
    end
  end
end
