require 'rails_helper'
require 'models/behaviours/event_behaviour'

RSpec.describe Events::Submission::Created do
  it_behaves_like 'an event' do
    let(:partial_path) { 'events/submission/created' }
  end

  it { is_expected.to have_data_reader(:submission_assets) }
  it { is_expected.to have_data_reader(:exercise_title) }
  it { is_expected.to have_data_reader(:exercise_id) }
  it { is_expected.to have_data_reader(:path) }
  it { is_expected.to have_data_reader(:submission_id) }

  describe '#file_count' do
    it 'returns the submission assets count' do
      subject.data = {
        submission_assets: {
          added: [1, 2, 3],
          updated: [4, 5],
          destroyed: [6]
        }
      }

      expect(subject.file_count).to eq(6)
    end
  end
end
