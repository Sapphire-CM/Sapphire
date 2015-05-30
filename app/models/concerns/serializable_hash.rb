module SerializableHash
  extend ActiveSupport::Concern

  module ClassMethods
    def serialize_hash(*attributes)
      attributes.each do |attribute|
        define_method(attribute) do
          if parsed_value = instance_variable_get("@#{attribute}")
            parsed_value
          else
            parsed_value = if result = read_attribute(attribute).presence
              YAML.load(result)
            else
              {}
            end
            instance_variable_set("@#{attribute}", parsed_value)
            parsed_value
          end
        end

        define_method("#{attribute}=".to_sym) do |value|
          write_attribute(attribute, YAML.dump(value))
        end
      end
    end
  end
end
