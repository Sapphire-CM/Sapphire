require 'rails_helper'

RSpec.shared_examples 'hash serialization' do |hash_attributes|
  hash_attributes.each do |attribute|
    it "provides ##{attribute}" do
      expect(subject).to respond_to(attribute)
    end

    it "provides ##{attribute}=(hash)" do
      expect(subject).to respond_to("#{attribute}=")
    end
  end
end
