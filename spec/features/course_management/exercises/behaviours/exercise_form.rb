require "rails_helper"

RSpec.shared_examples "Exercise Form" do
  scenario 'Setting minimum required points', js: true do
    visit base_path

    expect(page).not_to have_field("exercise_min_required_points")

    fill_in "Title", with: "Fancy Exercise"

    check "Minimum points required for positive grade"
    fill_in 'exercise_min_required_points', with: "20"

    click_button "Save"

    click_sub_nav_link "Administrate"
    expect(page).to have_field('exercise_min_required_points', with: "20")

    uncheck "Minimum points required for positive grade"

    expect(page).not_to have_field("exercise_min_required_points")
  end

  scenario 'Setting maximum points in total', js: true do
    visit base_path

    expect(page).not_to have_field("exercise_max_total_points")

    fill_in "Title", with: "Fancy Exercise"

    check "Maximum points in total"
    fill_in 'exercise_max_total_points', with: "25"

    click_button "Save"

    click_sub_nav_link "Administrate"
    expect(page).to have_field('exercise_max_total_points', with: "25")

    uncheck "Maximum points in total"

    expect(page).not_to have_field("exercise_max_total_points")
  end

  scenario 'Setting maximum upload size', js: true do
    visit base_path

    expect(page).not_to have_field("exercise_maximum_upload_size")

    fill_in "Title", with: "Fancy Exercise"

    check "Maximum upload size"
    fill_in 'exercise_maximum_upload_size', with: "30"

    click_button "Save"
    click_sub_nav_link "Administrate"

    expect(page).to have_field('exercise_maximum_upload_size', with: "30")

    uncheck "Maximum upload size"

    expect(page).not_to have_field("exercise_maximum_upload_size")
  end
end