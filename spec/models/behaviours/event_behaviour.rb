require 'rails_helper'

RSpec.shared_examples 'an event' do
  describe '#to_partial_path' do
    it 'returns the partial path for given event' do
      expect(subject.to_partial_path).to eq(partial_path)
    end
  end
end
