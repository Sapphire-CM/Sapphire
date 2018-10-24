require 'rails_helper'

RSpec.describe "Edit Tutorial Group" do
  let(:tutorial_group) { FactoryGirl.create(:tutorial_group) }
  let(:term) { tutorial_group.term }
  let(:account) { FactoryGirl.create(:account, :admin) }

  let(:described_path) { edit_term_tutorial_group_path(term, tutorial_group) }

  before :each do
    sign_in account
  end

  describe 'navigation' do
    scenario 'from the tutorial group details page' do
      visit term_tutorial_group_path(term, tutorial_group)

      click_side_nav_link "Administrate"

      expect(page).to have_current_path(described_path)
    end
  end

  describe 'Form' do
    let(:title) { "T 42"}
    let(:description) { "Lorem ipsum sed dolor"}

    scenario 'Changing title and description' do
      visit described_path

      fill_in "Title", with: title
      fill_in "Description", with: description

      click_button "Save"

      expect(page).to have_content("successfully updated")

      tutorial_group.reload

      expect(tutorial_group.title).to eq(title)
      expect(tutorial_group.description).to eq(description)
    end

    scenario 'Not filling in a title' do
      visit described_path

      fill_in "Title", with: ""

      click_button "Save"

      expect(page).not_to have_content("successfully updated")
      expect(page).to have_content("can't be blank")
    end
  end
end