require 'rails_helper'
require 'features/course_management/behaviours/exercise_side_navigation_behaviour'
require 'features/course_management/behaviours/exercise_sub_navigation_behaviour'

RSpec.feature 'Managing submissions as a staff member' do
  let(:account) { FactoryGirl.create(:account) }
  let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
  let(:term) { group_exercise.term }
  let!(:group_exercise) { FactoryGirl.create(:exercise) }

  before :each do
    sign_in(account)
  end

  describe 'behaviours' do
    let(:base_path) { exercise_submissions_path(group_exercise) }
    let(:exercise) { group_exercise }

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
      click_top_bar_link group_exercise.title
      click_sub_nav_link "Submissions"

      expect(page).to have_current_path(exercise_submissions_path(group_exercise))
    end

    context 'existing submissions for group exercise' do
      let(:another_tutorial_group) { FactoryGirl.create(:tutorial_group, :with_tutor, term: term) }
      let(:another_tutor) { another_tutorial_group.tutor_accounts.first }

      let!(:term_registrations) { FactoryGirl.create_list(:term_registration, 5, :with_student_group, term: term, tutorial_group: tutorial_group) }
      let!(:other_term_registrations) { FactoryGirl.create_list(:term_registration, 2, term: term, tutorial_group: another_tutorial_group) }

      let!(:submissions) { FactoryGirl.create_list(:submission, 5, :spreaded_submission_time, exercise: group_exercise) }
      let!(:other_submissions) { FactoryGirl.create_list(:submission, 2, :spreaded_submission_time, exercise: group_exercise) }
      let!(:unmatched_submissions) { FactoryGirl.create_list(:submission, 2, :spreaded_submission_time, exercise: group_exercise) }

      let(:student_groups) { term_registrations.map(&:student_group) }

      let!(:exercise_registrations) {
        term_registrations.zip(submissions).map { |tr, s|
          FactoryGirl.create(:exercise_registration, exercise: group_exercise, term_registration: tr, submission: s)
        }
      }
      let!(:other_exercise_registrations) {
        other_term_registrations.zip(other_submissions).map { |tr, s|
          FactoryGirl.create(:exercise_registration, exercise: group_exercise, term_registration: tr, submission: s)
        }
      }

      before :each do
        visit exercise_submissions_path(group_exercise)
      end

      scenario 'viewing submissions of own tutorial group' do
        within '.submission-list' do
          submissions.each do |submission|
            expect(page).to have_link("Files", href: submission_path(submission))
          end
        end
      end

      scenario 'viewing unmatched submissions', js: true do
        visit exercise_submissions_path(group_exercise)

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
        visit exercise_submissions_path(group_exercise)

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

    context 'exercise allowing bulk submission management' do
      let(:exercise) { FactoryGirl.create(:exercise, term: term, enable_bulk_submission_management: true) }

      scenario 'shows link to bulk operations' do
        visit exercise_submissions_path(exercise)

        expect(page).to have_link("Bulk Operation", href: new_exercise_submission_bulk_path(exercise))
      end
    end

    context 'exercise disallowing bulk submission management' do
      let(:exercise) { FactoryGirl.create(:exercise, term: term, enable_bulk_submission_management: false) }

      scenario 'shows link to bulk operations' do
        visit exercise_submissions_path(exercise)

        expect(page).not_to have_link("Bulk Operation", href: new_exercise_submission_bulk_path(exercise))
      end
    end
  end
end
