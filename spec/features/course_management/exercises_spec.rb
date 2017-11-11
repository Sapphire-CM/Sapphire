require 'rails_helper'

RSpec.feature 'Exercise Management' do
  let(:account) { FactoryGirl.create(:account, :admin) }
  let(:course) { FactoryGirl.create(:course) }
  let(:term) { FactoryGirl.create(:term, course: course) }
  let!(:exercise) { FactoryGirl.create(:exercise, term: term) }

  before(:each) do
    sign_in account
  end

  scenario 'navigating to exercise administration page' do
    visit root_path

    click_link exercise.term.title
    click_top_bar_link exercise.title

    click_sub_nav_link 'Administrate'
    expect(page).to have_current_path(edit_exercise_path(exercise))
  end

  scenario 'creating an exercise' do
    visit term_path(term)

    click_side_nav_link('Exercises')
    click_link 'Add Exercise'

    expect(page).to have_current_path(new_term_exercise_path(term))

    fill_in 'Title', with: 'My shiny new Exercise'

    expect do
      click_button 'Save'
    end.to change(Exercise, :count).by(1)

    expect(Exercise.last.title).to eq('My shiny new Exercise')
  end

  scenario 'updating exercise' do
    visit edit_exercise_path(exercise)

    expect(exercise.title).not_to eq('My fancy Exercise')

    fill_in 'Title', with: 'My fancy Exercise'
    click_button 'Save'

    exercise.reload

    expect(exercise.title).to eq('My fancy Exercise')
  end

  scenario 'removing an exercise' do
    visit edit_exercise_path(exercise)

    expect do
      click_link 'Delete Exercise'
    end.to change(Exercise, :count).by(-1)

    expect(Exercise.find_by(id: exercise.id)).not_to be_present
  end
end
