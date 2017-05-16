require 'rails_helper'

RSpec.feature 'Evaluating submissions' do
  let(:account) { FactoryGirl.create(:account, :admin) }
  let(:course) { FactoryGirl.create(:course) }
  let(:term) { FactoryGirl.create(:term, course: course) }
  let(:exercise) { FactoryGirl.create(:exercise, term: term) }
  let(:rating_group) { FactoryGirl.create(:rating_group, title: 'Test rating group', exercise: exercise, points: 10) }
  let!(:boolean_points_rating) { FactoryGirl.create(:rating, :boolean_points, title: 'Boolean Points Rating', rating_group: rating_group, value: -4) }
  let!(:boolean_percent_rating) { FactoryGirl.create(:rating, :boolean_percent, title: 'Boolean Percent Rating', rating_group: rating_group, value: -50) }
  let!(:value_points_rating) { FactoryGirl.create(:rating, :value_points, title: 'Value Points Rating', rating_group: rating_group, min_value: -6, max_value: 0) }
  let!(:value_percent_rating) { FactoryGirl.create(:rating, :value_percent, title: 'Value Percent Rating', rating_group: rating_group, min_value: -50, max_value: 0) }
  let!(:plagiarism_rating) { FactoryGirl.create(:rating, :plagiarism, title: 'Plagiarism Rating', rating_group: rating_group) }


  let(:submission_time) { Time.now - 10.minutes }
  let!(:previous_submission) { FactoryGirl.create(:submission, exercise: exercise, submitted_at: submission_time + 5.minutes) }
  let!(:submission) { FactoryGirl.create(:submission, exercise: exercise, submitted_at: submission_time) }
  let!(:next_submission) { FactoryGirl.create(:submission, exercise: exercise, submitted_at: submission_time - 5.minutes) }

  before :each do
    sign_in account
  end

  scenario 'navigating to submission evaluation page' do
    visit root_path

    click_top_bar_link(term.title)
    click_top_bar_link(exercise.title)

    within 'table tr:nth-child(2)' do
      click_link('Evaluate')
    end

    expect(page.current_path).to eq(single_evaluation_path(submission))
  end

  scenario 'changing a boolean value', js: true do
    visit single_evaluation_path(submission)

    click_link 'Boolean Points Rating'
    expect(page).to have_content('6 of 10 points')

    click_link 'Boolean Percent Rating'
    expect(page).to have_content('3 of 10 points')
  end

  scenario 'changing a number rating to a value within range', js: true do
    visit single_evaluation_path(submission)

    fill_in 'Value Points Rating', with: '-6'
    expect(page).to have_content('4 of 10 points')

    fill_in 'Value Percent Rating', with: '-25'
    expect(page).to have_content('3 of 10 points')
  end

  scenario 'changing a number rating to a value outside range'

  scenario 'navigating to next submission' do
    visit single_evaluation_path(submission)

    click_link 'Next'
    expect(page.current_path).to eq(single_evaluation_path(next_submission))
  end

  scenario 'navigating to previous submission' do
    visit single_evaluation_path(submission)

    click_link 'Prev'
    expect(page.current_path).to eq(single_evaluation_path(previous_submission))
  end

  scenario 'navigating to next submission, when none is present' do
    visit single_evaluation_path(next_submission)

    click_link 'Next'
    expect(page.current_path).to eq(exercise_submissions_path(exercise))
  end

  scenario 'navigating to previous submission, when none is present' do
    visit single_evaluation_path(previous_submission)

    click_link 'Prev'
    expect(page.current_path).to eq(exercise_submissions_path(exercise))
  end

  scenario 'navigating to submission tree' do
    visit single_evaluation_path(submission)

    click_link 'Files'
    expect(page.current_path).to eq(tree_submission_path(submission))
  end
end
