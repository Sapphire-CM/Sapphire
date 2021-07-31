require 'rails_helper'

RSpec.describe 'FactoryBot' do
  it 'passes linting' do
    expect do
      FactoryBot.lint traits: true
    end.not_to raise_error
  end
end
