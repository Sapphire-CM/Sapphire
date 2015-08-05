require 'rails_helper'

RSpec.describe "PhantomJS" do
  it 'is at version 1.9.8' do
    expect(%x(phantomjs --version).strip).to eq('1.9.8')
  end
end
