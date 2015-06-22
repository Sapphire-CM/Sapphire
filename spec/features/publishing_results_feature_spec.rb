require 'rails_helper'

RSpec.feature 'Publishing Exercise Results Feature', type: :feature do
  let(:account) { create(:account, :admin) }
  let(:term) { create(:term) }
  let!(:exercise) { create(:exercise, term: term, title: 'Test Exercise') }
  let!(:tutorial_group_1) { create(:tutorial_group, term: term, title: 'T1') }
  let!(:tutorial_group_2) { create(:tutorial_group, term: term, title: 'T2') }

  scenario 'publishing and concealing individual results' do
    sign_in account
    visit exercise_result_publications_path(exercise.id)

    click_on 'Publish T1'
    expect(page).to have_content('Successfully published results for Test Exercise for T1')

    click_on 'Publish T2'
    expect(page).to have_content('Successfully published results for Test Exercise for T2')

    click_on 'Conceal T1'
    expect(page).to have_content('Successfully concealed results for Test Exercise for T1')

    expect(ResultPublication.for(exercise: exercise, tutorial_group: tutorial_group_1)).to be_concealed
    expect(ResultPublication.for(exercise: exercise, tutorial_group: tutorial_group_2)).to be_published
  end

  scenario 'publishing all results of an exercise' do
    sign_in account
    visit exercise_result_publications_path(exercise.id)

    click_on 'Publish all'
    expect(page).to have_content('Successfully published all results for \'Test Exercise\'')

    expect(ResultPublication.for(exercise: exercise, tutorial_group: tutorial_group_1)).to be_published
    expect(ResultPublication.for(exercise: exercise, tutorial_group: tutorial_group_2)).to be_published
  end

  scenario 'concealing all results of an exercise' do
    exercise.result_publications.map(&:publish!)

    sign_in account
    visit exercise_result_publications_path(exercise.id)

    click_on 'Conceal all'
    expect(page).to have_content('Successfully concealed all results for \'Test Exercise\'')

    expect(ResultPublication.for(exercise: exercise, tutorial_group: tutorial_group_1)).to be_concealed
    expect(ResultPublication.for(exercise: exercise, tutorial_group: tutorial_group_2)).to be_concealed
  end
end
