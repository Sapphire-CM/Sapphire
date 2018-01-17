require 'rails_helper'
require_relative 'behaviours/event_behaviour'
require_relative 'behaviours/hash_serialization_behaviour'

RSpec.describe Event, type: :model do
  it_behaves_like 'an event' do
    let(:partial_path) { 'event' }
  end

  it_behaves_like 'hash serialization', %I(data)

  describe 'db columns' do
    it { is_expected.to have_db_column(:type).of_type(:string) }
    it { is_expected.to have_db_column(:data).of_type(:text) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:subject) }
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:term) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:account) }
    it { is_expected.to validate_presence_of(:term) }
  end

  context 'scoping' do
    describe '#for_term' do
      let(:term) { FactoryGirl.create(:term) }
      let(:another_term) { FactoryGirl.create(:term) }

      let!(:events_of_term) { FactoryGirl.create_list(:event, 3, term: term) }
      let!(:events_of_other_term) { FactoryGirl.create_list(:event, 3, term: another_term) }

      it 'returns events only related to given term' do
        expect(Event.for_term(term)).to match_array(events_of_term)
      end
    end

    describe '#time_ordered' do
      let(:term) { create(:term) }

      it 'returns events ordered by descending creation date' do
        event_1 = FactoryGirl.create(:event, term: term, created_at: 5.days.ago, updated_at: 5.days.ago)
        event_2 = FactoryGirl.create(:event, term: term, created_at: 3.days.ago, updated_at: 3.days.ago)
        event_3 = FactoryGirl.create(:event, term: term, created_at: 7.days.ago, updated_at: 7.days.ago)

        expect(Event.time_ordered).to eq([event_2, event_1, event_3])
      end
    end
  end

  describe '.data_reader' do
    class DummyEvent < Event
      data_reader :foo, :bar
    end

    subject { DummyEvent.new }

    let(:dummy_data) { double }

    it 'defines instance methods which access data[attribute]' do
      expect(subject).to receive(:data).and_return(dummy_data).twice
      expect(dummy_data).to receive(:[]).with(:foo).once.and_return('foo')
      expect(dummy_data).to receive(:[]).with(:bar).once.and_return('bar')

      expect(subject.foo).to eq('foo')
      expect(subject.bar).to eq('bar')
    end
  end
end
