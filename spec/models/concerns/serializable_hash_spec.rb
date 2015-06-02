require 'rails_helper'
require_relative '../behaviours/hash_serialization_behaviour'

RSpec.describe SerializableHash do
  class SerializableHash::TestDouble
    # mimic ActiveRecord::Base
    include ActiveModel::Model
    include ActiveModel::Validations

    include SerializableHash

    serialize_hash :data

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

  it_behaves_like 'hash serialization', %I(data) do
    subject { model }
  end
end
