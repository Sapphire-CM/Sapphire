require 'rails_helper'

RSpec.describe "Students list" do
  let!(:term) { FactoryBot.create(:term) }
  let(:account) { FactoryBot.create(:account, :admin) }

  let(:described_path) { term_students_path(term) }

  before :each do
    sign_in(account)
  end

  describe "navigation" do
    scenario "from the term show page" do
      visit term_path(term)

      click_side_nav_link "Students"

      expect(page).to have_current_path(described_path)
    end
  end

  describe 'students list' do
    let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
    let!(:student_term_registrations) { FactoryBot.create_list(:term_registration, 3, term: term, tutorial_group: tutorial_group) }

    scenario "Viewing basic information about the students" do
      student_term_registrations.second.update(points: 30)

      visit described_path

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
      visit described_path

      student_term_registrations.each do |term_registration|
        expect(page).to have_link("Show", href: term_student_path(term, term_registration))
      end
    end

    scenario 'is sortable' do
      visit described_path

      expect(page).to have_css("table.sortable")
    end

    scenario 'provides an add student link' do
      visit described_path

      within_main do
        within "table" do
          expect(page).to have_link("Add", href: new_term_student_path(term))
        end
      end
    end

    context 'as tutor' do
      let(:account) { FactoryBot.create(:account, :tutor) }
      let(:term) { account.term_registrations.last.term }

      scenario 'hides add link' do
        visit described_path

        within_main do
          expect(page).not_to have_link("Add")
        end
      end
    end
  end
end