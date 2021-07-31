require "rails_helper"
require 'features/course_management/behaviours/exercise_side_navigation_behaviour'

RSpec.feature "Exercises List" do
  let(:account) { FactoryBot.create(:account, :lecturer) }
  let(:term_registration) { account.term_registrations.last }
  let(:term) { term_registration.term }
  let(:course) { term.course }

  before(:each) do
    sign_in account
  end

  describe 'behaviours' do
    let(:base_path) { term_exercises_path(term) }

    it_behaves_like "Exercise Side Navigation"
  end

  scenario 'Navigating to the exercises list through sidenav' do
    visit term_path(term)

    click_side_nav_link "Exercises"

    expect(page).to have_current_path(term_exercises_path(term))
  end

  scenario 'Navigating to the exercises list through nav bar' do
    visit term_path(term)

    click_top_bar_link "Exercises"

    expect(page).to have_current_path(term_exercises_path(term))
  end

  context "without exercises" do
    scenario "Shows empty notice" do
      visit term_exercises_path(term)

      expect(page).to have_content("No exercises present.")
    end

    scenario "Shows add link" do
      visit term_exercises_path(term)

      expect(page).to have_link("Add Exercise", href: new_term_exercise_path(term))
    end
  end

  context 'with exercises' do
    let!(:exercises) { FactoryBot.create_list(:exercise, 3, term: term) }

    scenario "Lists all exercises" do
      exercises.first.update(group_submission: true)

      visit term_exercises_path(term)

      within("table.exercises") do
        exercises.each.with_index do |exercise, idx|

          within("tbody tr:nth-child(#{idx + 1})") do
            expect(page).to have_link(exercise.title, href: exercise_path(exercise))

            if exercise.group_submission?
              expect(page).to have_content("Group")
            else
              expect(page).to have_content("Individual")
            end
          end

        end
      end
    end

    scenario "Exercises table is sortable" do
      visit term_exercises_path(term)

      expect(page).to have_css("table.exercises.sortable")
    end

    context "as student" do
      let(:account) { FactoryBot.create(:account, :student) }

      scenario 'Does not show edit links' do
        visit term_exercises_path(term)

        exercises.each do |exercise|
          expect(page).not_to have_link(href: edit_exercise_path(exercise))
        end
      end
    end

    context "as lecturer" do
      scenario 'It shows edit links' do
        visit term_exercises_path(term)

        exercises.each do |exercise|
          expect(page).to have_link(href: edit_exercise_path(exercise))
        end
      end
    end
  end
end