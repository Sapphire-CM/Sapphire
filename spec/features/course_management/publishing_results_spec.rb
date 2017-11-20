require 'rails_helper'
require 'features/course_management/behaviours/exercise_side_navigation_behaviour'
require 'features/course_management/behaviours/exercise_sub_navigation_behaviour'

RSpec.feature 'Publishing Exercise Results Feature', type: :feature do
  let(:account) { create(:account, :admin) }
  let(:term) { create(:term) }
  let!(:exercise) { create(:exercise, term: term, title: 'Test Exercise') }
  let!(:tutorial_group_1) { create(:tutorial_group, term: term, title: 'T1') }
  let!(:tutorial_group_2) { create(:tutorial_group, term: term, title: 'T2') }

  before :each do
    sign_in account
  end

  describe 'behaviours' do
    let(:base_path) { exercise_result_publications_path(exercise) }

    it_behaves_like "Exercise Sub Navigation", [:admin, :lecturer]
    it_behaves_like "Exercise Side Navigation"
  end

  scenario 'publishing and concealing individual results' do
    visit exercise_result_publications_path(exercise)

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
    visit exercise_result_publications_path(exercise)

    click_on 'Publish all'
    expect(page).to have_content('Successfully published all results for \'Test Exercise\'')

    expect(ResultPublication.for(exercise: exercise, tutorial_group: tutorial_group_1)).to be_published
    expect(ResultPublication.for(exercise: exercise, tutorial_group: tutorial_group_2)).to be_published
  end

  scenario 'concealing all results of an exercise' do
    exercise.result_publications.map(&:publish!)

    visit exercise_result_publications_path(exercise.id)

    click_on 'Conceal all'
    expect(page).to have_content('Successfully concealed all results for \'Test Exercise\'')

    expect(ResultPublication.for(exercise: exercise, tutorial_group: tutorial_group_1)).to be_concealed
    expect(ResultPublication.for(exercise: exercise, tutorial_group: tutorial_group_2)).to be_concealed
  end
end
