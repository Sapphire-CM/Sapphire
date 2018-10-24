require 'rails_helper'

RSpec.feature 'Viewing Student Groups' do
  let(:account) { FactoryGirl.create(:account) }
  let(:term) { FactoryGirl.create(:term) }
  let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: term, account: account) }

  let(:described_path) { term_student_group_path(term, student_group) }

  before :each do
    sign_in account
  end

  let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
  let(:keyword) { "sapphire-course-management" }
  let(:topic) { "Sapphire Course Management" }
  let(:description) { "Student Group should evaluate sapphire" }

  let!(:student_group) { FactoryGirl.create(:student_group, tutorial_group: tutorial_group, keyword: keyword, topic: topic, description: description) }

  scenario 'Navigating to the show page from index page' do
    visit term_student_groups_path(term)

    click_link "Show"

    expect(page).to have_current_path(described_path)
  end

  scenario 'Highlighting link in side nav' do
    visit described_path

    within ".side-nav li.active" do
      expect(page).to have_link("Student Groups")
    end
  end

  scenario 'Viewing student group infos', js: true do
    visit described_path

    within ".info-panel" do
      expect(page).to have_content(keyword)
      expect(page).to have_content(topic)
      expect(page).to have_content(description)
    end
  end

  scenario 'Viewing students list with students' do
    student_term_registrations = FactoryGirl.create_list(:term_registration, 3, :student, term: term, tutorial_group: tutorial_group, student_group: student_group)
    students = student_term_registrations.map(&:account)

    visit described_path

    within ".students-table" do
      expect(page).to have_css("table.sortable")
      student_term_registrations.each do |student_term_registration|
        expect(page).to have_content(student_term_registration.account.fullname)
        expect(page).to have_link("show", href: term_student_path(term, student_term_registration))
        expect(page).to have_link(student_term_registration.account.email, href: "mailto:#{student_term_registration.account.email}")
      end
    end
  end

  scenario 'Viewing students list without students' do
    visit described_path

    within ".students-table" do
      expect(page).to have_content("No students present.")
    end
  end

  scenario 'Viewing submission list with submissions' do
    student_term_registrations = FactoryGirl.create_list(:term_registration, 3, :student, term: term, tutorial_group: tutorial_group, student_group: student_group)
    students = student_term_registrations.map(&:account)

    exercises = FactoryGirl.create_list(:exercise, 3, term: term)
    submissions = exercises.map do |exercise|
      submission = FactoryGirl.create(:submission, :evaluated, exercise: exercise, student_group: student_group)
      student_term_registrations.each do |student_term_registration|
        FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: student_term_registration, submission: submission)
      end

      submission.submission_evaluation.update(evaluation_result: 20)
      submission
    end

    visit described_path

    within ".submissions-table" do
      expect(page).to have_css("table.sortable")

      within "table.sortable" do
        submissions.each do |submission|
          expect(page).to have_content(submission.exercise.title)
          expect(page).to have_link("show", href: submission_path(submission))
          expect(page).to have_link("evaluate", href: submission_evaluation_path(submission.submission_evaluation))
        end

        within "tfoot" do
          expect(page).to have_content("Sum:")
          expect(page).to have_content("60 points")
        end
      end

    end
  end

  scenario 'Viewing submission list without students' do
    visit described_path

    within ".submissions-table" do
      expect(page).to have_content("This group has not submitted any submission.")
    end
  end
end