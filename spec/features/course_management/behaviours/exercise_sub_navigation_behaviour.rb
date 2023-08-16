require 'rails_helper'

RSpec.shared_examples "Exercise Sub Navigation" do |roles|
  roles = [:student, :tutor, :lecturer, :admin] if roles.blank? || roles.empty?

  let(:account) { term_registration.account }

  before(:each) do
    sign_in account
  end

  if roles.include?(:lecturer)
    context 'as lecturer' do
      let(:term_registration) { FactoryBot.create(:term_registration, :lecturer, term: exercise.term) }

      scenario "Provides sub navigation links" do
        visit base_path

        within ".sub-nav" do
          expect(page).to have_link("Exercise", href: exercise_path(exercise))
          expect(page).to have_link("Ratings", href: exercise_rating_groups_path(exercise))
          expect(page).to have_link("Submissions", href: exercise_submissions_path(exercise))
          expect(page).to have_link("Publish Results", href: exercise_result_publications_path(exercise))
          expect(page).to have_link("Services", href: term_exercise_services_path(exercise.term, exercise))
          expect(page).to have_link("Administrate", href: edit_exercise_path(exercise))
        end
      end
    end
  end

  if roles.include?(:tutor)
    context 'as tutor' do
      let(:term_registration) { FactoryBot.create(:term_registration, :tutor, term: exercise.term) }

      scenario "Provides sub navigation links" do
        visit base_path

        within ".sub-nav" do
          expect(page).to have_link("Exercise", href: exercise_path(exercise))
          expect(page).to have_link("Submissions", href: exercise_submissions_path(exercise))

          expect(page).not_to have_link("Ratings", href: exercise_rating_groups_path(exercise))
          expect(page).not_to have_link("Publish Results", href: exercise_result_publications_path(exercise))
          expect(page).not_to have_link("Services", href: term_exercise_services_path(exercise.term, exercise))
          expect(page).not_to have_link("Administrate", href: edit_exercise_path(exercise))
        end
      end
    end
  end

  if roles.include?(:student)
    context 'as student with submission' do
      let(:term_registration) { FactoryBot.create(:term_registration, :student, term: exercise.term) }
      let(:submission) { FactoryBot.create(:submission, exercise: exercise, submitter: account) }
      let(:result_publication) { ResultPublication.where(exercise: exercise, tutorial_group_id: term_registration.tutorial_group).first }
      let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }

      scenario "Provides sub navigation links with published results" do
        expect(result_publication.concealed?).to be_truthy

        result_publication.publish!

        visit base_path

        expect(result_publication.published?).to be_truthy

        within ".sub-nav" do
          expect(page).to have_link("Exercise", href: exercise_path(exercise))
          expect(page).to have_text("Submission")
          expect(page).to have_text("Results")

          expect(page).not_to have_link("Ratings", href: exercise_rating_groups_path(exercise))
          expect(page).not_to have_link("Submissions", href: exercise_submissions_path(exercise))
          expect(page).not_to have_link("Publish Results", href: exercise_result_publications_path(exercise))
          expect(page).not_to have_link("Services", href: term_exercise_services_path(exercise.term, exercise))
          expect(page).not_to have_link("Administrate", href: edit_exercise_path(exercise))
        end
      end

      scenario "Provides sub navigation links without published results" do
        visit base_path

        expect(result_publication.concealed?).to be_truthy

        within ".sub-nav" do
          expect(page).to have_link("Exercise", href: exercise_path(exercise))
          expect(page).to have_text("Submission")

          expect(page).not_to have_text("Results")
          expect(page).not_to have_link("Ratings", href: exercise_rating_groups_path(exercise))
          expect(page).not_to have_link("Submissions", href: exercise_submissions_path(exercise))
          expect(page).not_to have_link("Publish Results", href: exercise_result_publications_path(exercise))
          expect(page).not_to have_link("Services", href: term_exercise_services_path(exercise.term, exercise))
          expect(page).not_to have_link("Administrate", href: edit_exercise_path(exercise))
        end
      end
    end

    context 'as student without submission' do
      let(:term_registration) { FactoryBot.create(:term_registration, :student, term: exercise.term) }
      let(:result_publication) { ResultPublication.where(exercise: exercise, tutorial_group_id: term_registration.tutorial_group).first }

      scenario "Provides sub navigation links with published results" do
        expect(result_publication.concealed?).to be_truthy

        result_publication.publish!

        visit base_path

        expect(result_publication.published?).to be_truthy

        within ".sub-nav" do
          expect(page).to have_link("Exercise", href: exercise_path(exercise))
          expect(page).to have_text("Submission")

          expect(page).not_to have_text("Results")
          expect(page).not_to have_link("Ratings", href: exercise_rating_groups_path(exercise))
          expect(page).not_to have_link("Submissions", href: exercise_submissions_path(exercise))
          expect(page).not_to have_link("Publish Results", href: exercise_result_publications_path(exercise))
          expect(page).not_to have_link("Services", href: term_exercise_services_path(exercise.term, exercise))
          expect(page).not_to have_link("Administrate", href: edit_exercise_path(exercise))
        end
      end

      scenario "Provides sub navigation links without published results" do
        visit base_path

        expect(result_publication.concealed?).to be_truthy

        within ".sub-nav" do
          expect(page).to have_link("Exercise", href: exercise_path(exercise))
          expect(page).to have_text("Submission")

          expect(page).not_to have_text("Results")
          expect(page).not_to have_link("Ratings", href: exercise_rating_groups_path(exercise))
          expect(page).not_to have_link("Submissions", href: exercise_submissions_path(exercise))
          expect(page).not_to have_link("Publish Results", href: exercise_result_publications_path(exercise))
          expect(page).not_to have_link("Services", href: term_exercise_services_path(exercise.term, exercise))
          expect(page).not_to have_link("Administrate", href: edit_exercise_path(exercise))
        end
      end
    end
  end
end
