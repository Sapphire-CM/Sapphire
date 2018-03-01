require "rails_helper"

RSpec.describe "Viewing the points overview of a term" do
  let(:account) { FactoryGirl.create(:account, :admin) }
  let(:term) { FactoryGirl.create(:term) }

  let(:described_path) { points_overview_term_path(term) }

  before :each do
    sign_in account
  end

  describe 'navigation' do
    scenario 'through the term sidebar' do
      visit term_path(term)

      click_side_nav_link "Points Overview"

      expect(page).to have_current_path(described_path)
    end
  end


  describe 'points overview' do
    context 'with tutorial groups' do
      let!(:tutorial_groups) { FactoryGirl.create_list(:tutorial_group, 3, term: term) }
      let!(:tutor_term_registrations) { tutorial_groups.map { |tg| FactoryGirl.create(:term_registration, :tutor, term: term, tutorial_group: tg) } }

      scenario 'shows all tutorial groups and tutors' do
        visit described_path

        within_main do
          tutorial_groups.each do |tutorial_group|
            expect(page).to have_content(tutorial_group.title)
          end

          tutor_term_registrations.each do |term_registration|
            expect(page).to have_content(term_registration.account.fullname)
          end
        end
      end

      scenario 'shows the grading scale' do
        visit described_path

        expect(page).to have_css('#grading_scale')
      end
    end

    context 'with student results' do
      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let!(:student_term_registration) { FactoryGirl.create(:term_registration, :student, term: term, tutorial_group: tutorial_group) }
      let!(:exercise) { FactoryGirl.create(:exercise, term: term) }
      let!(:submission) { FactoryGirl.create(:submission, exercise: exercise) }
      let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: student_term_registration, submission: submission) }
      let(:student_account) { student_term_registration.account }

      scenario 'shows the student\'s results in a sortable table' do
        exercise_registration.update(points: 42)

        visit described_path

        within_main do
          within 'table.sortable' do
            expect(page).to have_content(42)
          end
        end
      end

      scenario 'shows the student\'s matriculation number in a sortable table' do
        visit described_path

        within_main do
          within 'table.sortable' do
            expect(page).to have_content(student_account.matriculation_number)
          end
        end
      end

      scenario 'hides the student\'s first name and last name' do
        visit described_path

        within_main do
          expect(page).not_to have_content(student_account.forename)
          expect(page).not_to have_content(student_account.surname)
        end
      end
    end
  end
end