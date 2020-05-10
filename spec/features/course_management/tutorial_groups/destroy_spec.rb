require 'rails_helper'

RSpec.describe "Removing tutorial group" do
  let(:tutorial_group) { FactoryGirl.create(:tutorial_group) }
  let(:term) { tutorial_group.term }
  let(:account) { FactoryGirl.create(:account, :admin) }

  let(:described_path) { edit_term_tutorial_group_path(term, tutorial_group) }

  before :each do
    sign_in account
  end

  scenario 'using the tutorial group edit page', js: true do
    visit described_path

    expect do
      accept_confirm do
        click_link "Delete Tutorial Group"
      end

      expect(page).to have_content("Tutorial group successfully deleted.")
    end.to change(TutorialGroup, :count).by(-1)
  end
end