require "rails_helper"
require 'features/course_management/behaviours/exercise_side_navigation_behaviour'
require 'features/course_management/behaviours/exercise_sub_navigation_behaviour'
require 'features/course_management/exercises/behaviours/exercise_form'

RSpec.feature "Exercises Editing" do
  let(:exercise) { FactoryBot.create(:exercise) }
  let(:term) { exercise.term }
  let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, account: account, term: term)}
  let(:account) { FactoryBot.create(:account) }

  before :each do
    sign_in account
  end

  describe 'behaviours' do
    let(:base_path) { edit_exercise_path(exercise) }

    it_behaves_like "Exercise Side Navigation"
    it_behaves_like "Exercise Sub Navigation", [:admin, :lecturer]
    it_behaves_like "Exercise Form"
  end

  scenario 'navigating to the edit page via exercises#show' do
    visit exercise_path(exercise)

    click_sub_nav_link("Administrate")

    expect(page).to have_current_path(edit_exercise_path(exercise))
  end

  scenario 'navigating to the edit page via exercises#index' do
    visit term_exercises_path(term)

    within 'table.exercises' do
      click_link href: edit_exercise_path(exercise)
    end

    expect(page).to have_current_path(edit_exercise_path(exercise))
  end

  scenario 'Changing exercise attributes' do
    visit edit_exercise_path(exercise)

    fill_in "Title", with: "Fancy Exercise"

    click_button "Save"

    expect(page).to have_current_path(exercise_path(exercise))
    expect(page).to have_content("Fancy Exercise")
    expect(page).to have_content("successfully updated")
  end
end
