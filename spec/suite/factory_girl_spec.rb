require 'rails_helper'

RSpec.describe 'FactoryGirl' do
  it 'passes linting' do
    expect do
      FactoryGirl.lint
    end.not_to raise_error
  end
end
