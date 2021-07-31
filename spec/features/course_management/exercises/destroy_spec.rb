require "rails_helper"
require 'features/course_management/behaviours/exercise_side_navigation_behaviour'
require 'features/course_management/behaviours/exercise_sub_navigation_behaviour'
require 'features/course_management/exercises/behaviours/exercise_form'

RSpec.feature "Exercise Destruction" do
  let(:exercise) { FactoryBot.create(:exercise) }
  let(:term) { exercise.term }
  let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, account: account, term: term)}
  let(:account) { FactoryBot.create(:account) }

  before :each do
    sign_in account
  end

  scenario 'Destroying exercises through the exercise edit page' do
    visit edit_exercise_path(exercise)

    expect do
      click_link "Delete Exercise"
    end.to change(Exercise, :count).by(-1)

    expect(page).to have_current_path(term_exercises_path(term))
    expect(page).to have_content("successfully deleted")
  end
end
