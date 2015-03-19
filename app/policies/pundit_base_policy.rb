class PunditBasePolicy
  attr_reader :user, :record

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def initialize(user, record)
    fail Pundit::NotAuthorizedError, 'must be logged in' unless user

    @user = user
    @record = record
  end

  def self.with(record)
    klass = self
    record.define_singleton_method(:policy_class) do
      # remove monkey-patched method
      # so that any further policy query (in a view) returns the original policy
      singleton_class.send :undef_method, :policy_class

      klass
    end
    record
  end
end
