require 'rails_helper'

RSpec.describe "Course Editing" do
  let(:account) { FactoryBot.create(:account, :admin) }
  let!(:course) { FactoryBot.create(:course) }

  before :each do
    sign_in account
  end

  shared_examples "Course Editing" do
    let(:new_course_title) { "My fancy course" }

    scenario "Updating title" do
      visit root_path

      within "#course_id_#{course.id}" do
        click_link href: edit_course_path(course)
      end

      fill_in "Title", with: new_course_title

      click_button "Save"

      expect(page).to have_current_path(root_path)
      expect(page).to have_content(new_course_title)
    end

    scenario "Not providing a title" do
      visit root_path

      within "#course_id_#{course.id}" do
        click_link href: edit_course_path(course)
      end

      fill_in "Title", with: ""

      click_button "Save"

      expect(page).to have_content("can't be blank")
    end
  end

  describe 'using JS', js: true do
    it_behaves_like "Course Editing"
  end

  describe 'without JS' do
    it_behaves_like "Course Editing"
  end
end