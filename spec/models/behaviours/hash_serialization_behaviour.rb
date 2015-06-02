require 'rails_helper'

RSpec.shared_examples 'hash serialization' do |hash_attributes|
  hash_attributes.each do |attribute|
    context "serialized ##{attribute} hash" do
      describe "##{attribute}" do
        it 'deserializes YAML-encoded attribute' do
          expect(subject).to receive(:read_attribute).with(attribute).and_return(YAML.dump(foo: 'bar'))

          expect(subject.send(attribute)).to match(foo: 'bar')
        end
      end

      describe "##{attribute}=" do
        it 'serializes given hash and writes it to attribute as YAML' do
          expect(subject).to receive(:write_attribute).with(attribute, YAML.dump(foo: 'bar'))

          subject.send("#{attribute}=".to_sym, foo: 'bar')
        end

        it 'stores value in instance variable' do
          expect(subject).to receive(:instance_variable_set).with("@#{attribute}", foo: 'bar')

          subject.send("#{attribute}=".to_sym, foo: 'bar')
        end
      end
    end
  end
end
