require "rails_helper"
require 'features/course_management/behaviours/exercise_side_navigation_behaviour'
require 'features/course_management/behaviours/exercise_sub_navigation_behaviour'

RSpec.describe 'Editing a submission' do
  let(:term) { FactoryBot.create(:term) }
  let(:account) { FactoryBot.create(:account) }
  let(:exercise) { FactoryBot.create(:exercise, term: term) }
  let(:submission) { FactoryBot.create(:submission, exercise: exercise) }

  let(:described_path) { edit_submission_path(submission) }

  before :each do
    sign_in(account)
  end

  describe 'behaviours' do
    let(:base_path) { described_path }

    it_behaves_like "Exercise Sub Navigation", [:admin, :lecturer, :tutor]
    it_behaves_like "Exercise Side Navigation" do
      before :each do
        account.update(admin: true)
      end
    end
  end

  shared_examples "Submission Editing" do
    describe 'navigation' do
      scenario 'through the submission tree page' do
        visit tree_submission_path(submission)

        within ".submission-tree-toolbar" do
          click_link("Edit")
        end

        expect(page).to have_current_path(described_path)
      end

      scenario 'through the evaluation page' do
        visit submission_evaluation_path(submission.submission_evaluation)

        within ".evaluation-top-bar" do
          click_link "Edit"
        end

        expect(page).to have_current_path(described_path)
      end

      context 'with student' do
        let!(:student_term_registration) { FactoryBot.create(:term_registration, :student, term: term) }
        let!(:student_exercise_registration) { FactoryBot.create(:exercise_registration, term_registration: student_term_registration, exercise: exercise, submission: submission) }

        scenario 'through the grading review page opens the edit page in a new window', js: true do
          visit term_grading_review_path(term, student_term_registration)

          within_main do
            click_link exercise.title

            within "section.active" do
              new_window = window_opened_by { click_link "Edit" }

              within_window new_window do
                expect(page).to have_current_path(described_path)
              end
            end
          end
        end
      end
    end

    describe "updating attributes" do
      let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
      let!(:student_groups) { FactoryBot.create_list(:student_group, 3, tutorial_group: tutorial_group) }
      let!(:student_term_registrations) { FactoryBot.create_list(:term_registration, 3, :student, term: term) }
      let(:other_student_term_registration) { student_term_registrations.last }
      let(:student_term_registration) { student_term_registrations.second }
      let(:lookup_string) { student_term_registration.account.matriculation_number }
      let!(:exercise_attempt) { FactoryBot.create(:exercise_attempt, exercise: exercise) }

      scenario 'Setting a student group' do
        visit described_path

        within "form" do
          select(student_groups.second.title)
          click_button "Submit"
        end

        expect(page).to have_content("Successful")
      end

      scenario 'Adding a student to the submission', js: true do
        visit described_path

        within 'form' do
          find("a[data-behaviour=add-item]").click
          fill_in(:subject_lookup, with: lookup_string)
        end

        within ".association-lookup-dropdown" do
          find("li:first-child").click
        end

        expect do
          click_button "Submit"
        end.to change(ExerciseRegistration, :count).by(1)
        expect(page).to have_content("Successful")
      end

      scenario 'Changing a student of the submission', js: true do
        submission.exercise_registrations.create(exercise: submission.exercise, term_registration: other_student_term_registration)

        visit described_path

        within 'form' do
          find("a[data-behaviour=edit-subject]").click
          fill_in(:subject_lookup, with: lookup_string)
        end

        within ".association-lookup-dropdown" do
          find("li:first-child").click
        end

        expect do
          click_button "Submit"
        end.not_to change(ExerciseRegistration, :count)

        expect(page).to have_content("Successful")
        expect(page).to have_content(student_term_registration.account.fullname)
      end

      scenario 'Removing an existing student from the submission', js: true do
        submission.exercise_registrations.create(exercise: submission.exercise, term_registration: other_student_term_registration)

        visit described_path

        within 'form' do
          find("a[data-behaviour=remove-item]").click
        end

        expect do
          click_button "Submit"
        end.to change(ExerciseRegistration, :count).by(-1)
        expect(page).to have_content("Successful")
        expect(page).not_to have_content(other_student_term_registration.account.fullname)
      end

      scenario 'Removing a newly added student from the submission', js: true do
        visit described_path

        within 'form' do
          find("a[data-behaviour=add-item]").click
          fill_in(:subject_lookup, with: lookup_string)
        end

        within ".association-lookup-dropdown" do
          find("li:first-child").click
        end

        within 'form' do
          find("a[data-behaviour=remove-item]").click
        end

        expect do
          click_button "Submit"
        end.not_to change(ExerciseRegistration, :count)
        expect(page).to have_content("Successful")
      end

      scenario 'Updating the submission attempt' do
        exercise.update(enable_multiple_attempts: true)

        visit described_path

        select exercise_attempt.title

        click_button "Submit"
      end
    end

    describe 'attempts field' do
      let(:exercise_attempt) { FactoryBot.create(:exercise_attempt, exercise: exercise) }

      it 'shows the attempts field if multiple attempts are enabled' do
        exercise.update(enable_multiple_attempts: true)

        visit described_path

        expect(page).to have_css("label", text: "Exercise attempt")
      end

      it 'shows the attempts field if an attempt is set' do
        submission.update(exercise_attempt: exercise_attempt)

        visit described_path

        expect(page).to have_css("label", text: "Exercise attempt")
      end

      it 'hides the attempts field if multiple attempts are disabled and no attempt is set' do
        exercise.update(enable_multiple_attempts: false)

        visit described_path

        expect(page).not_to have_css("label", text: "Exercise attempt")
      end
    end
  end

  describe 'as a lecturer' do
    let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, term: term, account: account) }

    it_behaves_like "Submission Editing"
  end
end