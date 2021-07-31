require "rails_helper"

RSpec.describe "Term Creation" do
  let(:account) { FactoryBot.create(:account, :admin) }
  let!(:course) { FactoryBot.create(:course) }

  before :each do
    sign_in account
  end

  shared_examples "Term Creation" do
    let(:term_title) { "My fancy term" }

    scenario 'Creating a term' do
      visit root_path

      within "#course_id_#{course.id}" do
        click_link href: new_term_path(course_id: course.id)
      end

      fill_in "Title", with: term_title

      click_button "Save"

      expect(page).to have_content("successfully created")
      expect(page).to have_current_path(term_path(Term.last))
    end

    scenario 'Not filling out title' do
      visit root_path

      within "#course_id_#{course.id}" do
        click_link href: new_term_path(course_id: course.id)
      end

      fill_in "Title", with: ""

      click_button "Save"

      expect(page).not_to have_content("successfully created")
      expect(page).to have_content("can't be blank")
    end
  end

  describe 'with JS', js: true do
    it_behaves_like "Term Creation"
  end

  describe 'without JS' do
    it_behaves_like "Term Creation"
  end
end