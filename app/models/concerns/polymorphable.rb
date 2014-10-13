module Polymorphable
  extend ActiveSupport::Concern

  included do
    cattr_accessor :polymorphic_definitions

    def self.polymorphic(definitions)
      @polymorphic_definitions = definitions.with_indifferent_access
    end

    def self.types
      @polymorphic_definitions.keys.map(&:to_s)
    end

    def self.valid_type?(type)
      types.include?(type)
    end

    def self.new_from_type(type, options = {})
      if type = @polymorphic_definitions[type]
        type.constantize.new(options)
      end
    end

    def self.class_from_type(type)
      if type = @polymorphic_definitions[type]
        type.constantize
      end
    end
  end
end