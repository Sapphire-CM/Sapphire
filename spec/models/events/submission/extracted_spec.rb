require 'rails_helper'
require 'models/behaviours/event_behaviour'

RSpec.describe Events::Submission::Extracted do
  it_behaves_like 'an event' do
    let(:partial_path) { 'events/submission/extracted' }
  end

  it { is_expected.to have_data_reader(:zip_file) }
  it { is_expected.to have_data_reader(:zip_path) }
  it { is_expected.to have_data_reader(:exercise_title) }
  it { is_expected.to have_data_reader(:exercise_id) }
  it { is_expected.to have_data_reader(:submission_id) }
  it { is_expected.to have_data_reader(:extracted_submission_assets) }

  describe '#file_count' do
    it 'returns the submission assets count' do
      subject.data = {
        extracted_submission_assets: (1..4).to_a
      }

      expect(subject.file_count).to eq(4)
    end
  end
end
