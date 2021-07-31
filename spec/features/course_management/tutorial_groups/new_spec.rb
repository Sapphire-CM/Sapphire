require 'rails_helper'

RSpec.describe "New Tutorial Group" do
  let(:term) { FactoryBot.create(:term) }
  let(:account) { FactoryBot.create(:account, :admin) }

  let(:described_path) { new_term_tutorial_group_path(term) }

  before :each do
    sign_in account
  end

  describe 'navigation' do
    scenario 'from the tutorial groups list' do
      visit term_tutorial_groups_path(term)

      click_link "New Tutorial Group"

      expect(page).to have_current_path(described_path)
    end
  end

  describe 'Form' do
    let(:title) { "T 99" }
    let(:description) { "Lorem ipsum sed dolor amet" }

    scenario 'Saving new tutorial group' do
      visit described_path

      fill_in "Title", with: title
      fill_in "Description", with: description

      expect do
        click_button "Save"
      end.to change(TutorialGroup, :count).by(1)

      expect(page).to have_content("Tutorial group successfully created.")
      expect(page).to have_current_path(term_tutorial_group_path(term, TutorialGroup.last))

      tutorial_group = TutorialGroup.last
      expect(tutorial_group.title).to eq(title)
      expect(tutorial_group.description).to eq(description)
    end

    scenario 'Not filling in a title' do
      visit described_path

      expect do
        click_button "Save"
      end.not_to change(TutorialGroup, :count)

      expect(page).to have_content("can't be blank")
    end

    scenario 'Cancelling navigates to tutorial groups list' do
      visit described_path

      click_link "Cancel"

      expect(page).to have_current_path(term_tutorial_groups_path(term))
    end
  end
end