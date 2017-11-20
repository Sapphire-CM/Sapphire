require 'rails_helper'

RSpec.shared_examples "Exercise Sub Navigation" do |roles|
  roles = [:student, :tutor, :lecturer, :admin] if roles.blank? || roles.empty?

  let(:account) { term_registration.account }
  let(:term) { exercise.term }

  before(:each) do
    sign_in account
  end

  if roles.include?(:lecturer)
    context 'as lecturer' do
      let(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: exercise.term) }

      scenario "Provides sub navigation links" do
        visit base_path

        within ".sub-nav" do
          expect(page).to have_link("Exercise", href: exercise_path(exercise))
          expect(page).to have_link("Ratings", href: exercise_rating_groups_path(exercise))
          expect(page).to have_link("Submissions", href: exercise_submissions_path(exercise))
          expect(page).to have_link("Publish Results", href: exercise_result_publications_path(exercise))
          expect(page).to have_link("Services", href: term_exercise_services_path(term, exercise))
          expect(page).to have_link("Administrate", href: edit_exercise_path(exercise))
        end
      end
    end
  end

  if roles.include?(:tutor)
    context 'as tutor' do
      let(:term_registration) { FactoryGirl.create(:term_registration, :tutor, term: exercise.term) }

      scenario "Provides sub navigation links" do
        visit base_path

        within ".sub-nav" do
          expect(page).to have_link("Exercise", href: exercise_path(exercise))
          expect(page).to have_link("Submissions", href: exercise_submissions_path(exercise))

          expect(page).not_to have_link("Ratings", href: exercise_rating_groups_path(exercise))
          expect(page).not_to have_link("Publish Results", href: exercise_result_publications_path(exercise))
          expect(page).not_to have_link("Services", href: term_exercise_services_path(term, exercise))
          expect(page).not_to have_link("Administrate", href: edit_exercise_path(exercise))
        end
      end
    end
  end

  if roles.include?(:student)
    context 'as student' do
      let(:term_registration) { FactoryGirl.create(:term_registration, :student, term: exercise.term) }

      scenario "Provides sub navigation links" do
        visit base_path

        within ".sub-nav" do
          expect(page).to have_link("Exercise", href: exercise_path(exercise))

          expect(page).not_to have_link("Ratings", href: exercise_rating_groups_path(exercise))
          expect(page).not_to have_link("Submissions", href: exercise_submissions_path(exercise))
          expect(page).not_to have_link("Publish Results", href: exercise_result_publications_path(exercise))
          expect(page).not_to have_link("Services", href: term_exercise_services_path(term, exercise))
          expect(page).not_to have_link("Administrate", href: edit_exercise_path(exercise))
        end
      end
    end
  end
end