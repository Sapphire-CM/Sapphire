require 'rails_helper'
require 'features/course_management/behaviours/exercise_side_navigation_behaviour'
require 'features/course_management/behaviours/exercise_sub_navigation_behaviour'

RSpec.feature 'Managing submissions as a staff member' do
  let(:account) { FactoryGirl.create(:account) }
  let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
  let(:term) { FactoryGirl.create(:term) }
  let!(:exercise) { FactoryGirl.create(:exercise, term: term) }

  let(:described_path) { exercise_submissions_path(exercise) }

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

  context 'as tutor' do
    let!(:term_registration) { FactoryGirl.create(:term_registration, :tutor, account: account, term: term, tutorial_group: tutorial_group) }

    scenario 'navigating to the submissions page' do
      visit root_path

      click_link term.title
      click_top_bar_link exercise.title
      click_sub_nav_link "Submissions"

      expect(page).to have_current_path(described_path)
    end

    context 'existing submissions for group exercise' do
      let(:another_tutorial_group) { FactoryGirl.create(:tutorial_group, :with_tutor, term: term) }
      let(:another_tutor) { another_tutorial_group.tutor_accounts.first }

      let!(:term_registrations) { FactoryGirl.create_list(:term_registration, 5, :with_student_group, term: term, tutorial_group: tutorial_group) }
      let!(:other_term_registrations) { FactoryGirl.create_list(:term_registration, 2, term: term, tutorial_group: another_tutorial_group) }

      let!(:submissions) { FactoryGirl.create_list(:submission, 5, :spreaded_submission_time, exercise: exercise) }
      let!(:other_submissions) { FactoryGirl.create_list(:submission, 2, :spreaded_submission_time, exercise: exercise) }
      let!(:unmatched_submissions) { FactoryGirl.create_list(:submission, 2, :spreaded_submission_time, exercise: exercise) }

      let(:student_groups) { term_registrations.map(&:student_group) }

      let!(:exercise_registrations) {
        term_registrations.zip(submissions).map { |tr, s|
          FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: tr, submission: s)
        }
      }
      let!(:other_exercise_registrations) {
        other_term_registrations.zip(other_submissions).map { |tr, s|
          FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: tr, submission: s)
        }
      }

      before :each do
        visit described_path
      end

      scenario 'viewing submissions of own tutorial group' do
        within '.submission-list' do
          submissions.each do |submission|
            expect(page).to have_link("Files", href: submission_path(submission))
          end
        end
      end

      scenario 'viewing unmatched submissions', js: true do
        visit described_path

        within '.tutorial-group-dropdown' do
          find_link(class: "dropdown").click
          click_link "Unmatched"

          expect(page).to have_content("Unmatched Submissions")
        end

        within '.submission-list' do
          expect(page).to have_content("unknown author")

          unmatched_submissions.each do |submission|
            expect(page).to have_link("Files", href: submission_path(submission))
          end
        end
      end

      scenario 'viewing all submissions', js: true do
        visit described_path

        within '.tutorial-group-dropdown' do
          find_link(class: "dropdown").click
          click_link "All"

          expect(page).to have_content("All Tutorial Groups")
        end

        within '.submission-list' do
          submissions.each do |submission|
            expect(page).to have_link("Files", href: submission_path(submission))
          end

          other_submissions.each do |submission|
            expect(page).to have_link("Files", href: submission_path(submission))
          end

          unmatched_submissions.each do |submission|
            expect(page).to have_link("Files", href: submission_path(submission))
          end
        end
      end

      scenario 'viewing submissions of other tutors', js: true do
        within '.tutorial-group-dropdown' do
          find_link(class: "dropdown").click
          click_link "#{another_tutorial_group.title} - #{another_tutor.fullname}"
        end

        within '.submission-list' do
          other_submissions.each do |submission|
            expect(page).to have_link("Files", href: submission_path(submission))
          end
        end
      end

      scenario 'ordering submissions', js: true do
        within '.submission-list' do
          student_groups.sort_by(&:title).each.with_index do |student_group, idx|
            expect(find("tbody tr:nth-child(#{idx + 1})")).to have_content(student_group.title)
          end

          find("a", text: "Submitted at").click

          submissions.sort_by(&:submitted_at).each.with_index do |submission, idx|
            expect(find("tbody tr:nth-child(#{idx + 1})")).to have_link("Files", href: submission_path(submission))
          end
        end
      end

      scenario 'clicking on group titles navigates to student group page' do
        student_group = student_groups.first

        within '.submission-list' do
          click_link student_group.title

          expect(page).to have_current_path(term_student_group_path(term, student_group))
        end
      end
    end

    describe 'table contents' do
      let!(:submission) { FactoryGirl.create(:submission, :active, exercise: exercise, submitted_at: submission_date, exercise_attempt: exercise_attempt) }
      let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, :recent, exercise: exercise, submission: submission, term_registration: student_term_registration) }
      let!(:student_term_registration) { FactoryGirl.create(:term_registration, :student, :with_student_group, term: term, tutorial_group: tutorial_group) }

      let(:submission_date) { 2.days.ago }
      let(:evaluation_date) { 1.day.ago }
      let(:submission_evaluation) { submission.submission_evaluation }
      let(:student_account) { student_term_registration.account }
      let(:student_group) { student_term_registration.student_group }

      let(:exercise_attempt) { exercise.attempts.first }

      context 'solitary submissions' do
        let!(:exercise) { FactoryGirl.create(:exercise, :solitary_exercise, term: term) }

        scenario 'viewing submission meta data' do
          submission_evaluation.update(evaluation_result: 30, evaluated_at: evaluation_date)

          visit described_path

          within '.submission-list' do
            expect(page).to have_content(student_account.fullname)
            expect(page).to have_content(student_account.matriculation_number)
            expect(page).to have_link(student_group.title)
            expect(page).to have_content("30 points")

            expect(page).to have_content(submission_date.strftime("%Y-%m-%d %H:%M"))
            expect(page).to have_content(evaluation_date.strftime("%Y-%m-%d %H:%M"))
          end
        end
      end

      context 'group submissions' do
        let!(:exercise) { FactoryGirl.create(:exercise, :group_exercise, term: term) }

        scenario 'viewing submission meta data' do
          submission_evaluation.update(evaluation_result: 30, evaluated_at: evaluation_date)

          visit described_path

          within '.submission-list' do
            expect(page).to have_link(student_group.title)
            expect(page).to have_content("30 points")

            expect(page).to have_content(submission_date.strftime("%Y-%m-%d %H:%M"))
            expect(page).to have_content(evaluation_date.strftime("%Y-%m-%d %H:%M"))
          end
        end
      end

      context 'exercise with multiple attempts' do
        let!(:exercise) { FactoryGirl.create(:exercise, :multiple_attempts, term: term) }

        scenario 'Shows attempt' do
          visit described_path

          within '.submission-list' do
            expect(page).to have_content(exercise_attempt.title)
          end
        end
      end

      context 'outdated submissions' do
        let(:exercise_attempt) { FactoryGirl.create(:exercise_attempt, exercise: exercise) }
        let(:student_term_registration) { FactoryGirl.create(:term_registration, :student, :with_student_group, term: term, tutorial_group: tutorial_group) }

        let!(:inactive_submission) { FactoryGirl.create(:submission, :inactive, exercise: exercise, submitted_at: submission_date, exercise_attempt: exercise_attempt) }
        let!(:outdated_exercise_registration) { FactoryGirl.create(:exercise_registration, :outdated, exercise: exercise, submission: inactive_submission, term_registration: student_term_registration) }

        scenario 'indicate inactiveness' do
          visit described_path

          within '.submission-list' do
            expect(page).to have_css("tr.inactive", count: 1)
          end
        end
      end
    end

    context 'exercise allowing bulk submission management' do
      let(:exercise) { FactoryGirl.create(:exercise, term: term, enable_bulk_submission_management: true) }

      scenario 'shows link to bulk operations' do
        visit described_path

        expect(page).to have_link("Bulk Operation", href: new_exercise_submission_bulk_path(exercise))
      end
    end

    context 'exercise disallowing bulk submission management' do
      let(:exercise) { FactoryGirl.create(:exercise, term: term, enable_bulk_submission_management: false) }

      scenario 'shows link to bulk operations' do
        visit described_path

        expect(page).not_to have_link("Bulk Operation", href: new_exercise_submission_bulk_path(exercise))
      end
    end
  end
end
