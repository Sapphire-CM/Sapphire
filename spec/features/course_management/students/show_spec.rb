require 'rails_helper'

RSpec.describe "Viewing students" do
  let(:term) { FactoryGirl.create(:term) }
  let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
  let(:account) { FactoryGirl.create(:account, :admin) }

  let(:described_path) { term_student_path(term, student_term_registration) }
  let!(:student_term_registration) { FactoryGirl.create(:term_registration, :student, :with_student_group, term: term, tutorial_group: tutorial_group) }

  before :each do
    sign_in(account)
  end

  describe 'navigation' do
    let!(:student_term_registration) { FactoryGirl.create(:term_registration, :student, term: term, tutorial_group: tutorial_group) }

    scenario 'from the students list' do
      visit term_students_path(term)

      within "table" do
        click_link "Show"
      end

      expect(page).to have_current_path(term_student_path(term, student_term_registration))
    end
  end

  describe 'student details' do
    let(:student_group) { student_term_registration.student_group }
    let(:exercise) { FactoryGirl.create(:exercise, term: term) }
    let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }
    let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, exercise: exercise, submission: submission, term_registration: student_term_registration) }

    scenario 'links the tutorial group' do
      visit described_path

      within_main do
        expect(page).to have_link(tutorial_group.title)
      end
    end

    scenario 'links the student group' do
      visit described_path

      expect(page).to have_link(student_group.title)
    end

    scenario 'lists the student\'s submissions' do
      visit described_path

      within "table" do
        expect(page).to have_content(exercise.title)
        expect(page).to have_link("Show")
        expect(page).to have_link("Evaluate")
      end
    end

    scenario 'states that the student does not have any submissions' do
      exercise_registration.destroy

      visit described_path

      expect(page).to have_content("No submissions for this student.")
    end

    scenario 'states that the student is not part of any student group' do
      student_term_registration.update(student_group: nil)

      visit described_path

      within ".panel" do
        expect(page).to have_content("None")
      end
    end

    scenario 'shows an edit link' do
      visit described_path

      within_main do
        expect(page).to have_link("Edit")
      end
    end

    scenario 'shows link to grading review' do
      visit described_path

      within_main do
        expect(page).to have_link("Grading Review")
      end
    end


    scenario 'shows a sortable submission table' do
      visit described_path

      within_main do
        within "table.sortable" do
          expect(page).to have_content(exercise.title)
        end
      end
    end
  end

  describe 'tutor adaptations' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:tutor_term_registration) { FactoryGirl.create(:term_registration, :tutor, term: term, account: account) }

    scenario 'hides the edit link' do
      visit described_path

      within_main do
        expect(page).not_to have_link("Edit")
      end
    end
  end
end