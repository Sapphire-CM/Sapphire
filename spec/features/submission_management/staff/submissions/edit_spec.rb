require "rails_helper"
require 'features/course_management/behaviours/exercise_side_navigation_behaviour'
require 'features/course_management/behaviours/exercise_sub_navigation_behaviour'

RSpec.describe 'Editing a submission' do
  let(:term) { FactoryGirl.create(:term) }
  let(:account) { FactoryGirl.create(:account) }
  let(:exercise) { FactoryGirl.create(:exercise, term: term) }
  let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }

  before :each do
    sign_in(account)
  end

  describe 'behaviours' do
    let(:base_path) { edit_submission_path(submission) }

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

        expect(page).to have_current_path(edit_submission_path(submission))
      end

      scenario 'through the evaluation page' do
        visit submission_evaluation_path(submission.submission_evaluation)

        within ".evaluation-top-bar" do
          click_link "Edit"
        end

        expect(page).to have_current_path(edit_submission_path(submission))
      end
    end

    describe "updating attributes" do
      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let!(:student_groups) { FactoryGirl.create_list(:student_group, 3, tutorial_group: tutorial_group) }
      let!(:student_term_registrations) { FactoryGirl.create_list(:term_registration, 3, :student, term: term) }
      let(:other_student_term_registration) { student_term_registrations.last }
      let(:student_term_registration) { student_term_registrations.second }
      let(:lookup_string) { student_term_registration.account.matriculation_number }

      scenario 'Setting a student group' do
        visit edit_submission_path(submission)

        within "form" do
          select(student_groups.second.title)
          click_button "Submit"
        end

        expect(page).to have_content("Successful")
      end

      scenario 'Adding a student to the submission', js: true do
        visit edit_submission_path(submission)

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

        visit edit_submission_path(submission)

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

        visit edit_submission_path(submission)

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
        visit edit_submission_path(submission)

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
    end
  end

  describe 'as a lecturer' do
    let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: term, account: account) }

    it_behaves_like "Submission Editing"
  end
end