require "rails_helper"
require 'features/course_management/behaviours/exercise_side_navigation_behaviour'
require 'features/course_management/behaviours/exercise_sub_navigation_behaviour'
require 'features/course_management/exercises/behaviours/exercise_form'

RSpec.feature "Creating Exercises" do
  let(:term) { FactoryGirl.create(:term) }
  let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, account: account, term: term)}
  let(:account) { FactoryGirl.create(:account) }

  before :each do
    sign_in account
  end

  describe 'behaviours' do
    let(:base_path) { new_term_exercise_path(term) }

    it_behaves_like "Exercise Side Navigation"
    it_behaves_like "Exercise Form"
  end

  scenario 'navigating to the edit page via exercises#show' do
    visit term_exercises_path(term)

    click_link "Add Exercise"

    expect(page).to have_current_path(new_term_exercise_path(term))
  end

  scenario 'Changing exercise attributes' do
    visit new_term_exercise_path(term)

    fill_in "Title", with: "Fancy Exercise"

    expect do
      click_button "Save"
    end.to change(Exercise, :count).by(1)

    expect(page).to have_current_path(exercise_path(Exercise.last))
    expect(page).to have_content("Fancy Exercise")
    expect(page).to have_content("successfully created")
  end
end
