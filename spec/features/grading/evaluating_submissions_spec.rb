require 'rails_helper'

RSpec.feature 'Evaluating submissions' do
  let(:account) { FactoryGirl.create(:account, :admin) }
  let(:course) { FactoryGirl.create(:course) }
  let(:term) { FactoryGirl.create(:term, course: course) }
  let(:exercise) { FactoryGirl.create(:exercise, :with_viewer, term: term) }

  let(:fixed_rating_group) { FactoryGirl.create(:rating_group, title: 'Fixed rating group', exercise: exercise, points: 10) }
  let!(:boolean_points_rating) { FactoryGirl.create(:fixed_points_deduction_rating, title: 'Boolean Points Rating', rating_group: fixed_rating_group, value: -4) }
  let!(:boolean_percent_rating) { FactoryGirl.create(:fixed_percentage_deduction_rating, title: 'Boolean Percent Rating', rating_group: fixed_rating_group, value: -50) }
  let!(:plagiarism_rating) { FactoryGirl.create(:plagiarism_rating, title: 'Plagiarism Rating', rating_group: fixed_rating_group) }

  let(:variable_rating_group) { FactoryGirl.create(:rating_group, title: 'Variable rating group', exercise: exercise, points: 10) }
  let!(:value_points_rating) { FactoryGirl.create(:variable_points_deduction_rating, title: 'Value Points Rating', rating_group: variable_rating_group, min_value: -6, max_value: 0) }
  let!(:value_percent_rating) { FactoryGirl.create(:variable_percentage_deduction_rating, title: 'Value Percent Rating', rating_group: variable_rating_group, min_value: -50, max_value: 0) }

  let(:fixed_evaluation_group) { fixed_rating_group.evaluation_groups.find_by(submission_evaluation: submission.submission_evaluation) }
  let(:variable_evaluation_group) { variable_rating_group.evaluation_groups.find_by(submission_evaluation: submission.submission_evaluation) }

  let(:submission_time) { Time.now - 10.minutes }
  let!(:submission) { FactoryGirl.create(:submission, exercise: exercise, submitted_at: submission_time) }

  before :each do
    sign_in account
  end

  describe 'navigating' do
    scenario 'to submission evaluation page from the root path' do
      visit root_path

      click_link(term.title)
      click_top_bar_link(exercise.title)
      click_sub_nav_link("Submissions")

      click_link('Evaluate')

      expect(page).to have_current_path(submission_evaluation_path(submission.submission_evaluation))
    end

    scenario 'to submission evaluation page through the submission tree' do
      visit tree_submission_path(submission)

      click_link('Evaluate')

      expect(page).to have_current_path(submission_evaluation_path(submission.submission_evaluation))
    end


    scenario 'to submission tree' do
      visit submission_evaluation_path(submission)

      click_link 'Files'
      expect(page).to have_current_path(tree_submission_path(submission))
    end
  end

  describe 'evaluation groups' do
    scenario 'closing and reopening evaluation groups', js: true do
      visit submission_evaluation_path(submission)

      within "#evaluation-group-#{fixed_evaluation_group.id}" do
        click_link 'Done'
      end

      expect(page).not_to have_content('Boolean Points Rating')

      within "#evaluation-group-#{fixed_evaluation_group.id}" do
        click_link 'Reopen'
      end

      expect(page).to have_content('Boolean Points Rating')
    end
  end

  describe 'changing values' do
    scenario 'a boolean value', js: true do
      visit submission_evaluation_path(submission)

      click_link boolean_points_rating.title
      expect(page).to have_content('16 of 20 points')

      click_link boolean_percent_rating.title
      expect(page).to have_content('13 of 20 points')

      click_link plagiarism_rating.title
      expect(page).to have_content('0 of 20 points')
    end

    scenario 'a number rating to a value within range', js: true do
      visit submission_evaluation_path(submission)

      fill_in 'Value Points Rating', with: '-6'
      expect(page).to have_content('4 of 20 points')

      fill_in 'Value Percent Rating', with: '-25'
      expect(page).to have_content('3 of 20 points')
    end

    scenario 'changing a number rating to a value outside range'
  end
end
