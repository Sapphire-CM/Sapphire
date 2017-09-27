require 'rails_helper'
require 'models/behaviours/event_behaviour'

RSpec.describe Events::StudentGroup::Updated do
  it_behaves_like 'an event' do
    let(:partial_path) { 'events/student_group/updated' }
  end

  it { is_expected.to have_data_reader(:student_group_title) }
  it { is_expected.to have_data_reader(:added_term_registrations) }
  it { is_expected.to have_data_reader(:removed_term_registrations) }
end