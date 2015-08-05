require 'rails_helper'

RSpec.feature 'Managing submissions as a staff member' do
  let!(:account) { FactoryGirl.create(:account) }
  let!(:term_registration) { FactoryGirl.create(:term_registration, :tutor, account: account, term: term) }
  let!(:tutorial_group) { term_registration.tutorial_group }
  let!(:term) { FactoryGirl.create(:term) }
  let!(:exercise) { FactoryGirl.create(:exercise, term: term) }

  before :each do
    sign_in(account)
  end

  scenario 'navigating to the submissions page' do
    visit root_path

    click_top_bar_link term.title
    click_top_bar_link exercise.title

    expect(page.current_path).to eq(exercise_submissions_path(exercise))
  end

  context 'existing submissions' do
    let!(:term_registrations) { FactoryGirl.create_list(:term_registration, 5, term: term, tutorial_group: tutorial_group) }

    let(:another_tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let!(:other_term_registrations) { FactoryGirl.create_list(:term_registration, 5, term: term, tutorial_group: another_tutorial_group) }


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
    let!(:submissions) { FactoryGirl.create_list(:submission, 5, :spreaded_submission_time, exercise: exercise) }
    let!(:other_submissions) { FactoryGirl.create_list(:submission, 5, :spreaded_submission_time, exercise: exercise) }
    let!(:unmatched_submissions) { FactoryGirl.create_list(:submission, 5, :spreaded_submission_time, exercise: exercise) }

    before :each do
      visit exercise_submissions_path(exercise)
    end

    scenario 'opening submission evaluations' do
      within 'table tbody tr:nth-child(1)' do
        click_link 'Evaluate'
      end

      expect(page.current_path).to eq(single_evaluation_path(submissions.first))
    end

    scenario 'opening submission' do
      within 'table tbody tr:nth-child(1)' do
        click_link 'Show'
      end

      expect(page.current_path).to eq(exercise_submission_path(exercise, submissions.first))
    end

    scenario 'viewing submissions of different tutorial groups' do
      within '#tutorial_group_dropdown' do
        click_link another_tutorial_group.title
      end

      within 'table tbody tr:nth-child(1)' do
        click_link 'Show'
      end

      expect(page.current_path).to eq(exercise_submission_path(exercise, other_submissions.first))
    end

    scenario 'viewing unmatched submissions' do
      within '#tutorial_group_dropdown' do
        click_link 'Unmatched'
      end

      within 'table tbody tr:nth-child(1)' do
        click_link 'Show'
      end

      expect(page.current_path).to eq(exercise_submission_path(exercise, unmatched_submissions.first))
    end

    scenario 'ordering submissions'
  end
end
