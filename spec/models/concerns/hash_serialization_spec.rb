require 'rails_helper'

RSpec.describe SerializableHash do
  class SerializableHash::TestDouble
    # mimic ActiveRecord::Base
    include ActiveModel::Model
    include ActiveModel::Validations

    include SerializableHash

    def read_attribute(_attr)
    end

    def write_attribute(_attr, _value)
    end
  end

  let(:model_class) { SerializableHash::TestDouble }
  let(:model) { model_class.new }

  describe '.serialize_hash' do
    it 'provides getter and setter methods' do
      model_class.serialize_hash(:foo, :bar)

      expect(model).to respond_to(:foo)
      expect(model).to respond_to(:foo=)
      expect(model).to respond_to(:bar)
      expect(model).to respond_to(:bar=)

      model_class.instance_eval { remove_method :foo }
      model_class.instance_eval { remove_method :foo= }

      model_class.instance_eval { remove_method :bar }
      model_class.instance_eval { remove_method :bar= }
    end
  end

  context 'serialized #data hash' do
    before :each do
      model_class.serialize_hash(:data)
    end

    after :each do
      model_class.instance_eval { remove_method :data }
      model_class.instance_eval { remove_method :data= }
    end

    describe '#data' do
      it 'deserializes YAML-encoded attribute' do
        expect(model).to receive(:read_attribute).with(:data).and_return(YAML.dump({foo: 'bar'}))

        expect(model.data).to match({foo: 'bar'})
      end
    end

    describe '#data=' do
      it 'serializes given hash and writes it to attribute as YAML' do
        expect(model).to receive(:write_attribute).with(:data, YAML.dump({foo: 'bar'}))

        model.data = {foo: 'bar'}
      end
    end
  end
end
