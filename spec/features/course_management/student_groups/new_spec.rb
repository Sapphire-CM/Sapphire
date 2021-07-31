require "rails_helper"

RSpec.feature 'Adding Student Groups' do
  let(:account) { FactoryGirl.create(:account) }
  let(:term) { FactoryGirl.create(:term) }
  let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: term, account: account) }

  let(:described_path) { new_term_student_group_path(term) }

  before :each do
    sign_in account
  end

  scenario 'Navigating to new form' do
    visit term_student_groups_path(term)

    click_link "New Student Group"

    expect(page).to have_current_path(described_path)
  end

  scenario 'Highlighting link in side nav' do
    visit described_path

    within ".side-nav li.active" do
      expect(page).to have_link("Student Groups")
    end
  end

  scenario 'Adding a new student group' do
    tutorial_group = FactoryGirl.create(:tutorial_group, term: term)

    visit described_path

    expect(page).to have_content("New Student Group")

    fill_in "Title", with: "Test Group"
    fill_in "Topic", with: "Sapphire Course Management"
    fill_in "Keyword", with: "sapphire-evaluation"
    fill_in "Description", with: "Test Group should evaluate the submissions page"
    select "#{tutorial_group.title} - (no tutor)", from: "Tutorial group"

    expect do
      click_button "Save"
    end.to change(StudentGroup, :count).by 1

    expect(page).to have_current_path(term_student_group_path(term, StudentGroup.last))

    within '.info-panel' do
      expect(page).to have_content("Test Group")
      expect(page).to have_content(tutorial_group.title)
      expect(page).to have_content("Sapphire Course Management")
      expect(page).to have_content("sapphire-evaluation")
      expect(page).to have_content("Test Group should evaluate the submissions page")
    end
  end

  scenario "Searching for and adding students", js: true do
    student_term_registration = FactoryGirl.create(:term_registration, :student, term: term)
    student = student_term_registration.account

    tutorial_group = FactoryGirl.create(:tutorial_group, term: term)

    visit described_path

    fill_in "Title", with: "Test Group"
    select "#{tutorial_group.title} - (no tutor)", from: "Tutorial group"

    fill_in "Search for students", with: student.fullname

    expect(page).not_to have_content("Start Typing")

    draggable = find(".term-registration-entry")
    droppable = find(".student-group-list-container")

    draggable.drag_to droppable

    click_button "Save"

    expect(page).not_to have_content("New Student Group")
    expect(page).to have_content("Test Group")

    within ".students-table" do
      expect(page).to have_content(student.forename)
      expect(page).to have_content(student.surname)
    end
  end

  scenario 'Not filling out title shows validation errors' do
    tutorial_group = FactoryGirl.create(:tutorial_group, term: term)

    visit described_path

    fill_in "Title", with: ""

    expect do
      click_button "Save"
    end.not_to change(StudentGroup, :count)

    expect(page).to have_content("New Student Group")
    expect(page).to have_content("can't be blank")
  end

  scenario 'Canceling adding new student group' do
    visit described_path

    click_link "Cancel"

    expect(page).to have_current_path(term_student_groups_path(term))
  end
end
