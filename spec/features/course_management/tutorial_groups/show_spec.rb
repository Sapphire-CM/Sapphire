require 'rails_helper'

RSpec.describe "Tutorial Group Detail" do
  let(:tutorial_group) { FactoryGirl.create(:tutorial_group) }
  let(:term) { tutorial_group.term }
  let(:account) { FactoryGirl.create(:account, :admin) }

  let(:described_path) { term_tutorial_group_path(term, tutorial_group) }

  before :each do
    sign_in account
  end

  describe 'navigation' do
    scenario 'from the tutorial groups list' do
      visit term_tutorial_groups_path(term)

      within_main do
        click_link tutorial_group.title
      end

      expect(page).to have_current_path(described_path)
    end

    scenario 'from term dashboard top bar' do
      visit term_path(term)

      click_top_bar_link tutorial_group.title

      expect(page).to have_current_path(described_path)
    end
  end

  describe 'info panel' do
    before :each do
      within ".info-panel"
    end

    scenario 'shows panel if description is present' do
      tutorial_group.update(description: "Lorem ipsum")

      visit described_path

      within ".info-panel" do
        expect(page).to have_selector(".panel")
        expect(page).to have_content("Lorem ipsum")
      end
    end

    scenario 'hides panel if description is blank' do
      tutorial_group.update(description: nil)
      visit described_path

      within ".info-panel" do
        expect(page).not_to have_selector(".panel")
      end
    end
  end

  describe 'students table' do
    context 'with students' do
      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, :with_students) }
      let(:student_term_registrations) { tutorial_group.student_term_registrations }

      scenario 'shows a sortable table' do
        visit described_path

        within ".students-table" do
          expect(page).to have_selector("table.sortable")
        end
      end

      scenario 'shows key attribtues of students' do
        visit described_path

        within '.students-table' do
          student_term_registrations.each do |student_term_registration|
            student = student_term_registration.account

            expect(page).to have_link(student.email)
            expect(page).to have_content(student.forename)
            expect(page).to have_content(student.surname)
            expect(page).to have_content(student.matriculation_number)
            expect(page).to have_link("show", href: term_student_path(term, student_term_registration))
          end
        end
      end
    end

    context 'without students' do
      scenario 'shows an empty notice and hides table' do
        visit described_path

        within '.students-table' do
          expect(page).to have_content("No students present.")
          expect(page).not_to have_selector("table")
        end
      end
    end

  end
end