require 'rails_helper'

RSpec.describe "Course Creation" do
  let(:account) { FactoryGirl.create(:account, :admin) }

  before :each do
    sign_in account
  end

  shared_examples "Course Creation" do
    let(:new_course_title) { "My fancy course" }

    scenario "Creating a course" do
      visit root_path

      click_link "Add Course"

      fill_in "Title", with: new_course_title

      click_button "Save"

      expect(page).to have_current_path(root_path)
      expect(page).to have_content(new_course_title)
    end
  end

  describe 'using JS', js: true do
    it_behaves_like "Course Creation"
  end

  describe 'without JS' do
    it_behaves_like "Course Creation"
  end
end