require 'rails_helper'

RSpec.describe 'PhantomJS' do
  it 'is at version 2.1.1' do
    expect(`phantomjs --version`.strip).to eq('2.1.1')
  end
end
