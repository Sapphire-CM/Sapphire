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
    it 'needs to be implemented'
  end

  describe '#only_updates?' do
    it 'needs to be implemented'
  end

  describe '#only_removals?' do
    it 'needs to be implemented'
  end

  describe '#additions' do
    it 'needs to be implemented'
  end

  describe '#updates' do
    it 'needs to be implemented'
  end

  describe '#removals' do
    it 'needs to be implemented'
  end
end
