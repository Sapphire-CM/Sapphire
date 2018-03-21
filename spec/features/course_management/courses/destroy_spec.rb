require 'rails_helper'

RSpec.describe "Course Removal" do
  let(:account) { FactoryGirl.create(:account, :admin) }
  let!(:course) { FactoryGirl.create(:course) }

  before :each do
    sign_in account
  end

  describe 'with JS', js: true do
    scenario 'Deleting courses' do
      visit root_path

      within "#course_id_#{course.id}" do
        accept_alert do
          click_link href: course_path(course)
        end
      end

      expect(page).to have_current_path(root_path)
      expect(page).not_to have_content(course.title)
      expect(page).to have_content("No courses present")
    end
  end

  describe 'without JS' do
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
end