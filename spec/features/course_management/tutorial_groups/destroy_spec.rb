require 'rails_helper'

RSpec.describe "Removing tutorial group" do
  let(:tutorial_group) { FactoryBot.create(:tutorial_group) }
  let(:term) { tutorial_group.term }
  let(:account) { FactoryBot.create(:account, :admin) }

  let(:described_path) { edit_term_tutorial_group_path(term, tutorial_group) }

  before :each do
    sign_in account
  end

  scenario 'using the tutorial group edit page', js: true do
    visit described_path

    expect do
      page.accept_alert do
        click_link "Delete Tutorial Group"
      end
    end.to change(TutorialGroup, :count).by(-1)
  end
end