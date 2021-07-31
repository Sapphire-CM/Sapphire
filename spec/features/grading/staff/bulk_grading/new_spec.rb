require 'rails_helper'

RSpec.describe 'Bulk Grading', :doing do
  let(:term) { FactoryBot.create(:term) }
  let(:account) { FactoryBot.create(:account) }
  let!(:term_registration) { FactoryBot.create(:term_registration, :tutor, term: term, account: account) }
  let!(:exercise) { FactoryBot.create(:exercise, :bulk_operations, term: term)}

  let(:described_path) { new_exercise_bulk_grading_path(exercise) }

  before :each do
    sign_in(account)
  end

  describe 'navigation' do
    scenario 'through the submissions list' do
      visit exercise_submissions_path(exercise)

      click_link "Bulk Grading"

      expect(page).to have_current_path(described_path)
    end
  end

  describe 'Form' do
    shared_examples "submission bulk form" do
      let(:rating_group) { FactoryBot.create(:rating_group, exercise: exercise, points: 10) }
      let!(:rating) { FactoryBot.create(:variable_points_deduction_rating, :bulk, rating_group: rating_group) }

      let(:table_css_query) { "form.bulk-grading table"}
      let(:dropdown_css_query) { ".association-lookup-dropdown" }
      let(:success_message) { "Successfully completed" }

      def row_css_query(number)
        "#{table_css_query} tbody tr:nth-child(#{number})"
      end

      def fill_in_value(value = -4)
        find("input[type=text]").set(value)
      end

      def select_first_dropdown_item
        within dropdown_css_query do
          find("li:first-child").click
        end

        # wait for dropdown to disappear
        expect(page).not_to have_css(dropdown_css_query)
      end

      def click_remove_button
        find("[data-behaviour=remove-item]").click
      end

      describe 'basic functionality' do
        let!(:exercise) { FactoryBot.create(:exercise, :bulk_operations, exercise_factory_trait, term: term) }

        scenario 'initially shows a table within a form with appropriate titles' do
          visit described_path

          within table_css_query do

            within "thead" do
              within "th:nth-child(1)" do
                expect(page).to have_content(subject_header)
              end

              within "th:nth-child(2)" do
                expect(page).to have_content(rating.title)
              end
            end

          end
          expect(page).to have_css(row_css_query(1))
          expect(page).not_to have_css(row_css_query(2))

        end

        scenario 'filling out the form', js: true do
          visit described_path

          within row_css_query(1) do
            fill_in :subject_lookup, with: new_subject_query
          end
          select_first_dropdown_item

          within row_css_query(1) do
            fill_in_value
          end

          within row_css_query(2) do
            fill_in :subject_lookup, with: existing_subject_query
          end
          select_first_dropdown_item

          within row_css_query(2) do
            fill_in_value
          end

          expect do
            click_button "Submit"
          end.to change(Submission, :count).by(1)
          expect(page).to have_content(success_message)
        end

        scenario 'filling out the form with invalid values', js: true do
          visit described_path

          within row_css_query(1) do
            fill_in :subject_lookup, with: new_subject_query
          end
          select_first_dropdown_item

          within row_css_query(1) do
            fill_in_value "2"
          end

          expect do
            click_button "Submit"
          end.not_to change(Submission, :count)
          expect(page).not_to have_content(success_message)
          expect(page).to have_content("must be between")
        end

        scenario 'removing items from the form', js: true do
          visit described_path

          within row_css_query(1) do
            fill_in :subject_lookup, with: new_subject_query
          end
          select_first_dropdown_item

          within row_css_query(2) do
            fill_in :subject_lookup, with: existing_subject_query
          end
          select_first_dropdown_item

          expect(page).to have_content(new_subject_query)
          expect(page).to have_content(existing_subject_query)

          within row_css_query(1) do
            click_remove_button
            click_remove_button
          end
          expect(page).not_to have_content(new_subject_query)
          expect(page).not_to have_content(existing_subject_query)
          expect(page).not_to have_css(row_css_query(2))
        end
      end

      describe 'exercise with single attempt' do
        let!(:exercise) { FactoryBot.create(:exercise, :bulk_operations, :single_attempt, exercise_factory_trait, term: term) }

        scenario 'hides the exercise attempt selector' do
          visit described_path

          expect(page).not_to have_content("Select Attempt")
        end
      end

      describe 'exercise with multiple attempts' do
        let!(:exercise) { FactoryBot.create(:exercise, :bulk_operations, :multiple_attempts, exercise_factory_trait, term: term) }
        let(:attempt) { exercise.attempts.first }

        scenario 'shows the exercise attempt selector' do
          visit described_path

          expect(page).to have_content("Select Attempt")
        end

        scenario "filling out the form and selecting an exercise attempt", js: true do
          visit described_path

          select attempt.title

          within row_css_query(1) do
            fill_in :subject_lookup, with: existing_subject_query
          end

          select_first_dropdown_item

          within row_css_query(1) do
            fill_in_value
          end

          expect do
            click_button "Submit"
          end.to change(Submission, :count).by(1)
          expect(page).to have_content(success_message)
        end
      end

    end

    context 'solitary exercise' do
      let!(:new_term_registration) { FactoryBot.create(:term_registration, :student, term: term) }
      let!(:term_registration_with_submission) { FactoryBot.create(:term_registration, :student, term: term) }

      let!(:submission) { FactoryBot.create(:submission, exercise: exercise) }
      let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: term_registration_with_submission, submission: submission) }

      it_behaves_like "submission bulk form" do
        let(:subject_header) { "Student" }
        let(:exercise_factory_trait) { :solitary_exercise }
        let(:new_subject_query) { new_term_registration.account.matriculation_number }
        let(:existing_subject_query) { term_registration_with_submission.account.matriculation_number }
      end
    end

    context 'group exercise' do
      let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }

      let!(:new_student_group) { FactoryBot.create(:student_group, tutorial_group: tutorial_group) }
      let!(:student_group_with_submission) { FactoryBot.create(:student_group, tutorial_group: tutorial_group) }

      let!(:submission) { FactoryBot.create(:submission, exercise: exercise, student_group: student_group_with_submission) }

      it_behaves_like "submission bulk form" do
        let(:subject_header) { "Group" }
        let(:exercise_factory_trait) { :group_exercise }
        let(:new_subject_query) { new_student_group.title }
        let(:existing_subject_query) { student_group_with_submission.title }
      end
    end
  end
end