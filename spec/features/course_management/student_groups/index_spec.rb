require "rails_helper"

RSpec.feature 'Student Group List' do
  let(:account) { FactoryGirl.create(:account) }
  let(:term) { FactoryGirl.create(:term) }
  let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: term, account: account) }

  before :each do
    sign_in account
  end


  scenario 'Navigating to the student groups page' do
    visit term_path(term)

    within '.side-nav' do
      click_link "Student Groups"
    end

    expect(page).to have_current_path(term_student_groups_path(term))
  end

  context 'without student groups' do
    scenario "Visiting student groups list shows empty notice" do
      visit term_student_groups_path(term)

      expect(page).to have_content("No student groups present")
    end
  end

  context "with student groups" do
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let!(:student_groups) { FactoryGirl.create_list(:student_group, 3, tutorial_group: tutorial_group) }

    scenario 'Student groups table is sortable' do
      visit term_student_groups_path(term)

      expect(page).to have_css("table.sortable")
    end

    scenario 'Viewing student groups' do
      visit term_student_groups_path(term)

      within "table.student-groups" do
        within "tbody tr:nth-child(2)" do
          expect(page).to have_content(student_groups.second.title)
          expect(page).to have_content(tutorial_group.title)

          expect(page).to have_link("Show", href: term_student_group_path(term, student_groups.second))
          expect(page).to have_link("Edit", href: edit_term_student_group_path(term, student_groups.second))
        end
      end
    end
  end
end