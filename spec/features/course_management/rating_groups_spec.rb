require 'rails_helper'

RSpec.feature 'Ratings and Rating Groups' do
  scenario 'navigating to the ratings page'

  describe 'Rating Groups' do
    scenario 'creating a rating group'
    scenario 'updating rating group'
    scenario 'updating point range of rating groups'
    scenario 'reordering of rating groups'
    scenario 'removing a rating group'
  end

  describe 'Ratings' do
    scenario 'creating a rating'
    scenario 'updating rating'
    scenario 'reordering of ratings'
    scenario 'moving rating to another rating group'
    scenario 'removing a rating'
  end
end
