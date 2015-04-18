module SerializedProperties
  extend ActiveSupport::Concern

  included do
    after_initialize :ensure_properties_hash

    serialize :properties

    def self.properties
      @properties || []
    end

    def self.prop_accessor(*names)
      @properties ||= []
      @properties += names

      names.each do |name|
        define_method(name) do
          properties[name]
        end

        define_method("#{name}=") do |value|
          self.properties ||= {}
          self.properties[name] = value
        end
      end
    end

    private

    def ensure_properties_hash
      self.properties ||= {}
    end
  end
end
