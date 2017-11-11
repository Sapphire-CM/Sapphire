require 'rails_helper'
require 'features/course_management/behaviours/exercise_side_navigation_behaviour'
require 'features/course_management/behaviours/exercise_sub_navigation_behaviour'

RSpec.describe "Exercise Page" do
  let(:account) { term_registration.account }
  let(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: term) }
  let(:term) { exercise.term }
  let(:course) { term.course }
  let!(:exercise) { FactoryGirl.create(:exercise) }

  before(:each) do
    sign_in account
  end

  context 'behaviours' do
    let(:base_path) { exercise_path(exercise) }

    it_behaves_like "Exercise Side Navigation"
    it_behaves_like "Exercise Sub Navigation"
  end

  scenario "Navigating to exercise page through exercises list" do
    visit term_exercises_path(term)

    within "table.exercises" do
      click_link exercise.title
    end

    expect(page).to have_current_path(exercise_path(exercise))
  end

  scenario "Navigating to exercise page through nav bar" do
    visit term_path(term)

    click_top_bar_link exercise.title

    expect(page).to have_current_path(exercise_path(exercise))
  end

  scenario "Viewing details of the exercise" do
    visit exercise_path(exercise)

  end
end