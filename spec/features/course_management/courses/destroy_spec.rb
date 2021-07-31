require 'rails_helper'

RSpec.describe "Course Removal" do
  let(:account) { FactoryBot.create(:account, :admin) }
  let!(:course) { FactoryBot.create(:course) }

  before :each do
    sign_in account
  end

  shared_examples "Course Removal" do
    scenario 'Deleting courses' do
      visit root_path

      within "#course_id_#{course.id}" do
        click_link href: course_path(course)
      end

      expect(page).to have_current_path(root_path)
      expect(page).not_to have_content(course.title)
      expect(page).to have_content("No courses present")
    end
  end

  describe 'with JS', js: true do
    it_behaves_like "Course Removal"
  end

  describe 'without JS' do
    it_behaves_like "Course Removal"
  end
end