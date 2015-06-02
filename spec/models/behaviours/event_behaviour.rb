require 'rails_helper'

RSpec.shared_examples 'an event' do
  it { is_expected.to belong_to(:subject) }
  it { is_expected.to belong_to(:account) }
  it { is_expected.to belong_to(:term) }
  it { is_expected.to validate_presence_of(:account) }
  it { is_expected.to validate_presence_of(:term) }

  describe '#to_partial_path' do
    it 'returns the partial path for given event' do
      expect(subject.to_partial_path).to eq(partial_path)
    end
  end
end
