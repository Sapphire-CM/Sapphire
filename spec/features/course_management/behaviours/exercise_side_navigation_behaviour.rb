require 'rails_helper'

RSpec.shared_examples "Exercise Side Navigation" do
  scenario "Highlighting exercises in side nav" do
    visit base_path

    within ".side-nav li.active" do
      expect(page).to have_link("Exercises")
    end
  end
end