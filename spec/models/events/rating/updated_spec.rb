require 'rails_helper'
require 'models/behaviours/event_behaviour'

RSpec.describe Events::Rating::Updated do
  it_behaves_like "an event" do
    let(:partial_path) { "events/rating/updated" }
  end

  it { is_expected.to have_data_reader(:exercise_title) }
  it { is_expected.to have_data_reader(:exercise_id) }
  it { is_expected.to have_data_reader(:rating_title) }
  it { is_expected.to have_data_reader(:rating_group_title) }
  it { is_expected.to have_data_reader(:rating_group_id) }

  describe '#tracked_changes' do
    it 'needs to be implemented'
  end
end
