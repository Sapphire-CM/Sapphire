require 'rails_helper'
require 'models/behaviours/event_behaviour'

RSpec.describe Events::Submission::Updated do
  it_behaves_like "an event" do
    let(:partial_path) { "events/submission/updated" }
  end

  it { is_expected.to have_data_reader(:submission_assets) }
  it { is_expected.to have_data_reader(:exercise_title) }
  it { is_expected.to have_data_reader(:exercise_id) }
  it { is_expected.to have_data_reader(:path) }
  it { is_expected.to have_data_reader(:submission_id) }

  describe '#only_additions?' do
    it 'returns false when no additions have been made' do
      subject.data = {
        submission_assets: {
          added: [],
          updated: [],
          destroyed: []
        }
      }

      expect(subject.only_additions?).to be_falsey
    end

    it 'returns false when updates and additions have been made' do
      subject.data = {
        submission_assets: {
          added: [1],
          updated: [2],
          destroyed: []
        }
      }

      expect(subject.only_additions?).to be_falsey
    end

    it 'returns false when removals and additions have been made' do
      subject.data = {
        submission_assets: {
          added: [1],
          updated: [],
          destroyed: [1]
        }
      }

      expect(subject.only_additions?).to be_falsey
    end


    it 'returns false when only additions have been made' do
      subject.data = {
        submission_assets: {
          added: [1],
          updated: [],
          destroyed: []
        }
      }

      expect(subject.only_additions?).to be_truthy
    end
  end

  describe '#only_updates?' do
    it 'returns false when no updates have been made' do
      subject.data = {
        submission_assets: {
          added: [],
          updated: [],
          destroyed: []
        }
      }

      expect(subject.only_updates?).to be_falsey
    end

    it 'returns false when additions and updates have been made' do
      subject.data = {
        submission_assets: {
          added: [1],
          updated: [2],
          destroyed: []
        }
      }

      expect(subject.only_updates?).to be_falsey
    end

    it 'returns false when removals and updates have been made' do
      subject.data = {
        submission_assets: {
          added: [],
          updated: [1],
          destroyed: [2]
        }
      }

      expect(subject.only_updates?).to be_falsey
    end


    it 'returns false when only updates have been made' do
      subject.data = {
        submission_assets: {
          added: [],
          updated: [1],
          destroyed: []
        }
      }

      expect(subject.only_updates?).to be_truthy
    end
  end

  describe '#only_removals?' do
    it 'returns false when no removals have been made' do
      subject.data = {
        submission_assets: {
          added: [],
          updated: [],
          destroyed: []
        }
      }

      expect(subject.only_removals?).to be_falsey
    end

    it 'returns false when additions and removals have been made' do
      subject.data = {
        submission_assets: {
          added: [1],
          updated: [],
          destroyed: [2]
        }
      }

      expect(subject.only_removals?).to be_falsey
    end

    it 'returns false when updates and removals have been made' do
      subject.data = {
        submission_assets: {
          added: [],
          updated: [1],
          destroyed: [2]
        }
      }

      expect(subject.only_removals?).to be_falsey
    end


    it 'returns false when only removals have been made' do
      subject.data = {
        submission_assets: {
          added: [],
          updated: [],
          destroyed: [1]
        }
      }

      expect(subject.only_removals?).to be_truthy
    end
  end

  context 'changes' do
    before :each do
      subject.data = {
        submission_assets: {
          added: %w(a d d e d),
          updated: %w(u p d a t e d),
          destroyed: %w(d e s t r o y e d)
        }
      }
    end

    describe '#additions' do
      it 'returns tracked submission asset additions' do
        expect(subject.additions).to match_array(%w(a d d e d))
      end
    end

    describe '#updates' do
      it 'returns tracked submission asset updates' do
        expect(subject.updates).to match_array(%w(u p d a t e d))
      end
    end

    describe '#removals' do
      it 'returns tracked submission asset removals' do
        expect(subject.removals).to match_array(%w(d e s t r o y e d))
      end
    end
  end
end
