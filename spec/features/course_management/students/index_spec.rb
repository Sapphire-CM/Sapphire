require 'rails_helper'

RSpec.describe "Students list" do
  let!(:term) { FactoryGirl.create(:term) }
  let(:account) { FactoryGirl.create(:account, :admin) }

  before :each do
    sign_in(account)
  end

  describe "navigation" do
    scenario "from the term show page" do
      visit term_path(term)

      click_side_nav_link "Students"

      expect(page).to have_current_path(term_students_path(term))
    end
  end

  describe 'students list' do
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let!(:student_term_registrations) { FactoryGirl.create_list(:term_registration, 3, term: term, tutorial_group: tutorial_group) }

    scenario "Viewing basic information about the students" do
      student_term_registrations.second.update(points: 30)

      visit term_students_path(term)

      within "table" do
        student_term_registrations.each do |term_registration|
          expect(page).to have_content(term_registration.account.fullname)
          expect(page).to have_content(term_registration.account.matriculation_number)
          expect(page).to have_content(term_registration.tutorial_group.title)
          expect(page).to have_content(term_registration.points)
        end
      end
    end

    scenario "Provides links to students detail page" do
      visit term_students_path(term)

      student_term_registrations.each do |term_registration|
        expect(page).to have_link("Show", href: term_student_path(term, term_registration))
      end
    end

    scenario 'is sortable' do
      visit term_students_path(term)

      expect(page).to have_css("table.sortable")
    end
  end
end