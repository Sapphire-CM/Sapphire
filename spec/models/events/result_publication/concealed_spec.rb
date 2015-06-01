require 'rails_helper'
require 'models/behaviours/event_behaviour'

RSpec.describe Events::ResultPublication::Concealed do
  it_behaves_like "an event" do
    let(:partial_path) { "events/result_publication/concealed" }
  end

  it { is_expected.to have_data_reader(:exercise_id) }
  it { is_expected.to have_data_reader(:exercise_title) }
  it { is_expected.to have_data_reader(:tutorial_group_id) }
  it { is_expected.to have_data_reader(:tutorial_group_title) }
end
