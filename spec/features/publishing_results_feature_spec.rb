require 'rails_helper'

RSpec.describe 'Publishing Exercise Results Feature' do
  it 'works' do
    account = FactoryGirl.create :account, :admin
    term = FactoryGirl.create :term
    exercise = FactoryGirl.create :exercise, term: term, title: 'Test Exercise'
    tutorial_group = FactoryGirl.create :tutorial_group, term: term, title: 'T1'

    sign_in account
    visit exercise_result_publications_path(exercise.id)
    click_on 'Publish T1'

    expect(page).to have_content('Successfully published results for Test Exercise for T1')
    expect(page).to have_button('Conceal T1')

    click_on 'Conceal T1'

    expect(page).to have_content('Successfully concealed results for Test Exercise for T1')
  end
end
