require 'rails_helper'

RSpec.describe 'Adding a new student term registration' do
  let(:term) { FactoryGirl.create(:term) }
  let(:account) { FactoryGirl.create(:account, :admin) }

  before :each do
    sign_in account
  end

  describe 'navigation' do
    scenario 'from the students list page' do
      visit term_students_path(term)

      within_main do
        click_link "Add"
      end

      expect(page).to have_current_path(new_term_student_path(term))
    end
  end

  describe 'Form' do
    let(:described_path) { new_term_student_path(term) }

    let!(:student_account) { FactoryGirl.create(:account) }
    let!(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let!(:student_group) { FactoryGirl.create(:student_group, tutorial_group: tutorial_group) }

    scenario 'Creating a new record', js: true do
      visit described_path

      fill_in(:subject_lookup, with: student_account.fullname)
      within ".association-lookup-dropdown" do
        find("li:first-child").click
      end

      select(tutorial_group.title)
      select(student_group.title)

      expect do
        click_button "Save"
      end.to change(TermRegistration, :count).by(1)

      expect(page).to have_current_path(term_student_path(term, TermRegistration.last))
      expect(page).to have_content("successfully")

      within_header do
        expect(page).to have_content(student_account.fullname)
      end

      within_main do
        expect(page).to have_content(tutorial_group.title)
        expect(page).to have_content(student_group.title)
      end
    end

    scenario 'Showing student account details after trying to save invalid record', js: true do
      visit described_path

      fill_in(:subject_lookup, with: student_account.fullname)
      within ".association-lookup-dropdown" do
        find("li:first-child").click
      end

      expect do
        click_button "Save"
      end.not_to change(TermRegistration, :count)

      within_main do
        expect(page).to have_content(student_account.fullname)
        expect(page).to have_content(student_account.matriculation_number)
        expect(page).to have_content(student_account.email)
      end
    end

    scenario 'Clicking cancel button' do
      visit described_path

      click_link "Cancel"

      expect(page).to have_current_path(term_students_path(term))
    end
  end
end