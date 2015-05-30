require 'rails_helper'
require_relative 'behaviours/event_behaviour'
require_relative 'behaviours/hash_serialization_behaviour'

RSpec.describe Event, :type => :model do
  it_behaves_like 'an event' do
    let(:partial_path) { 'event' }
  end

  it_behaves_like 'hash serialization', %I(data)
end
