require 'rails_helper'

RSpec.feature 'Grading Review Page' do
  let!(:account) { FactoryBot.create(:account, :admin) }

  let!(:term) { FactoryBot.create(:term) }
  let!(:term_registration) { FactoryBot.create(:term_registration, :student, term: term, account: student_account) }

  let(:described_path) { term_grading_review_path(term, term_registration) }

  let(:student_account) { FactoryBot.create(:account, forename: 'Max', surname: 'Mustermann') }

  before :each do
    sign_in account
  end

  describe 'navigation' do
    scenario 'through the grading review list' do
      visit term_grading_reviews_path(term)

      fill_in :q, with: 'Max Muster'
      click_button 'Search'

      expect(page).to have_content('Max Mustermann')
      first('.small.button', text: 'Show').click

      expect(page).to have_current_path(described_path)
    end

    scenario 'through the students detail page' do
      visit term_student_path(term, term_registration)

      within_main do
        click_link "Grading Review"
      end

      expect(page).to have_current_path(described_path)
    end
  end

  describe 'grading review' do
    let!(:term_registration) { FactoryBot.create(:term_registration, :student, term: term, account: student_account) }
    let!(:another_term_registration) { FactoryBot.create(:term_registration, :student, term: term) }
    let!(:exercise) { FactoryBot.create(:exercise, title: 'My Exercise', term: term) }
    let!(:rating_group) { FactoryBot.create(:rating_group, :with_ratings, exercise: exercise, points: 10) }
    let!(:submission) { FactoryBot.create(:submission, :evaluated, exercise: exercise) }
    let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }

    let(:exercise_attempt) { FactoryBot.create(:exercise_attempt, exercise: exercise) }
    let(:submission_evaluation) { submission.submission_evaluation }

    scenario 'starts with the overview tab open', js: true do
      visit described_path

      within_main do
        within "section.active .title" do
          expect(page).to have_content("Overview")
        end
      end
    end

    describe 'overview' do
      scenario 'viewing a student\'s results', js: true do
        visit described_path

        within_main do
          click_link 'Overview'

          within 'table' do
            expect(page).to have_content(exercise.title)
            expect(page).to have_content("10 / 10")
          end
        end
      end

      scenario 'showing a sortable overview table' do
        visit described_path

        within_main do
          expect(page).to have_css("table.sortable.submission-list", count: 1)
        end
      end

      scenario 'marking inactive submissions', js: true do
        submission.update(active: false)

        visit described_path

        within_main do
          click_link 'Overview'

          within 'table tr.inactive' do
            expect(page).to have_content(exercise.title)
          end
        end
      end

      scenario 'showing exercise attempt' do
        submission.update(exercise_attempt: exercise_attempt)

        visit described_path

        click_link 'Overview'

        within 'table' do
          expect(page).to have_content(exercise_attempt.title)
        end
      end
    end

    describe 'submission detail tab' do
      scenario 'shows the exercise attempt', js: true do
        submission.update(exercise_attempt: exercise_attempt)

        visit described_path

        within_main do
          click_link exercise.title

          within "section .content" do
            expect(page).to have_content(exercise_attempt.title)
          end
        end
      end

      scenario 'provides link to reopen submission', js: true do
        visit described_path

        within_main do
          click_link exercise.title

          within "section .content" do
            expect(page).to have_link("Reopen Evaluation")
          end
        end
      end

      scenario 'provides link to edit submission', js: true do
        visit described_path

        within_main do
          click_link exercise.title

          within "section .content" do
            expect(page).to have_link("Edit")
          end
        end
      end

      scenario 'shows points sum', js: true do
        submission.reload
        exercise.update(enable_max_total_points: true, max_total_points: 50)
        submission_evaluation.update(evaluation_result: 42)

        visit described_path

        within_main do
          click_link exercise.title

          within "section .content" do
            expect(page).to have_content("42 / 50")
          end
        end
      end

      scenario 'indicates inactiveness', js: true do
        submission.update(active: false)

        visit described_path

        within_main do
          click_link exercise.title

          expect(page).to have_content("Inactive Submission")
        end
      end

      scenario 'shows individual subtractions', js: true do
        exercise_registration.update(individual_subtractions: -42)

        visit described_path

        within_main do
          click_link exercise.title

          within "section .content" do
            expect(page).to have_content("Individual Subtractions")
            expect(page).to have_content("-42 points")
          end
        end
      end

      context 'with ratings' do
        let(:exercise) { FactoryBot.create(:exercise, :with_ratings, term: term) }
        let(:evaluation_group) { submission_evaluation.evaluation_groups.first }
        let(:evaluation) { evaluation_group.evaluations.first }
        let(:rating) { evaluation.rating }

        scenario 'shows failed evaluations', js: true do
          submission.reload
          evaluation.update(value: 1)

          visit described_path

          within_main do
            click_link exercise.title

            within "section .content" do
              expect(page).to have_content(rating.title)
              expect(page).to have_content(rating.value)
              expect(page).to have_content(evaluation_group.title)
              expect(page).to have_content(evaluation_group.points)
            end
          end
        end
      end

      context "with submission assets" do
        let!(:submission_asset) { FactoryBot.create(:submission_asset, submission: submission) }

        scenario 'shows submission assets', js: true do
          visit described_path

          within_main do
            click_link exercise.title

            within "section .content" do
              expect(page).to have_content(submission_asset.filename)
            end
          end
        end
      end

      context "with viewer" do
        let(:exercise) { FactoryBot.create(:exercise, :with_viewer, term: term) }

        scenario 'provides link to open submission viewer', js: true do
          visit described_path

          within_main do
            click_link exercise.title

            within "section .content" do
              expect(page).to have_link("Open Viewer")
            end
          end
        end
      end

      context "without viewer" do
        let(:exercise) { FactoryBot.create(:exercise, :without_viewer, term: term) }

        scenario 'hides link to open submission viewer', js: true do
          visit described_path

          within_main do
            click_link exercise.title

            within "section .content" do
              expect(page).not_to have_link("Open Viewer")
            end
          end
        end
      end
    end
  end
end
