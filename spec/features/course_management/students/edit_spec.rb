require 'rails_helper'

RSpec.describe 'Editing a student term registration' do
  let(:term) { FactoryGirl.create(:term) }
  let(:account) { FactoryGirl.create(:account, :admin) }
  let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
  let!(:other_tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
  let!(:student_term_registration) { FactoryGirl.create(:term_registration, :student, term: term, tutorial_group: tutorial_group) }

  before :each do
    sign_in account
  end

  describe 'navigation' do
    scenario 'from the student detail page' do
      visit term_student_path(term, student_term_registration)

      within_main do
        click_link "Edit"
      end

      expect(page).to have_current_path(edit_term_student_path(term, student_term_registration))
    end
  end

  describe 'Form' do
    let(:described_path) { edit_term_student_path(term, student_term_registration) }

    let!(:student_group) { FactoryGirl.create(:student_group, tutorial_group: tutorial_group) }
    let!(:other_student_group) { FactoryGirl.create(:student_group, tutorial_group: tutorial_group) }
    let(:student_account) { student_term_registration.account }

    scenario 'Shows details about the student\'s account' do
      visit described_path

      within_main do
        expect(page).to have_content(student_account.fullname)
        expect(page).to have_content(student_account.matriculation_number)
        expect(page).to have_content(student_account.email)
      end
    end

    scenario 'Clicking save button' do
      visit described_path

      click_button "Save"

      expect(page).to have_content("successfully")
      expect(page).to have_current_path(term_student_path(term, student_term_registration))
    end

    scenario 'Clicking cancel button' do
      visit described_path

      click_link "Cancel"

      expect(page).to have_current_path(term_student_path(term, student_term_registration))
    end

    scenario 'Changing the tutorial group' do
      visit described_path

      select(other_tutorial_group.title)

      click_button "Save"

      within_main do
        expect(page).to have_content(other_tutorial_group.title)
      end
    end

    scenario 'Changing the student group' do
      visit described_path

      select(other_student_group.title)

      click_button "Save"

      within_main do
        expect(page).to have_content(other_student_group.title)
      end
    end
  end
end