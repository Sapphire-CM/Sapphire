require "rails_helper"

RSpec.feature 'Updating Student Groups' do
  let(:account) { FactoryBot.create(:account) }
  let(:term) { FactoryBot.create(:term) }
  let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, term: term, account: account) }

  before :each do
    sign_in account
  end

  let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
  let!(:student_group) { FactoryBot.create(:student_group, tutorial_group: tutorial_group) }

  scenario 'Navigating to the edit page from index page' do
    visit term_student_groups_path(term)

    click_link "Edit"

    expect(page).to have_current_path(edit_term_student_group_path(term, student_group))
  end

  scenario 'Navigating to the edit page from detail page' do
    visit term_student_group_path(term, student_group)

    click_link "Edit"

    expect(page).to have_current_path(edit_term_student_group_path(term, student_group))
  end

  scenario 'Highlighting link in side nav' do
    visit edit_term_student_group_path(term, student_group)

    within ".side-nav li.active" do
      expect(page).to have_link("Student Groups")
    end
  end

  scenario 'Updating a student group' do
    other_tutorial_group = FactoryBot.create(:tutorial_group, term: term)

    visit edit_term_student_group_path(term, student_group)

    expect(page).to have_content("Edit Student Group")

    fill_in "Title", with: "Other Group"
    fill_in "Topic", with: "Sapphire Course Management"
    fill_in "Keyword", with: "sapphire-evaluation"
    fill_in "Description", with: "Test Group should evaluate the submissions page"
    select "#{other_tutorial_group.title} - (no tutor)", from: "Tutorial group"

    click_button "Save"

    expect(page).to have_current_path(term_student_group_path(term, student_group))
    expect(page).not_to have_content("Edit Student Group")
  end

  scenario 'Not filling out title shows validation error' do
    tutorial_group = FactoryBot.create(:tutorial_group, term: term)

    visit edit_term_student_group_path(term, student_group)

    fill_in "Title", with: ""

    click_button "Save"

    expect(page).to have_current_path(term_student_group_path(term, student_group))
    expect(page).to have_content("can't be blank")
  end

  scenario "Searching for and adding students", js: true do
    student_term_registration = FactoryBot.create(:term_registration, :student, term: term)
    student = student_term_registration.account

    tutorial_group = FactoryBot.create(:tutorial_group, term: term)

    visit edit_term_student_group_path(term, student_group)

    fill_in "Search for students", with: student.fullname

    expect(page).not_to have_content("Start Typing")

    draggable = find(".term-registration-entry")
    droppable = find(".student-group-list-container")

    draggable.drag_to droppable

    click_button "Save"

    expect(page).not_to have_content("Edit Student Group")

    within ".students-table" do
      expect(page).to have_content(student.forename)
      expect(page).to have_content(student.surname)
    end
  end

  scenario 'Canceling editing' do
    visit edit_term_student_group_path(term, student_group)

    click_link "Cancel"

    expect(page).to have_current_path(term_student_group_path(term, student_group))
  end
end
