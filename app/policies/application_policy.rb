require 'ostruct'

class ApplicationPolicy
  attr_reader :user, :record

  def self.policy_record_with(options = {})
    klass = self
    options[:klass] = klass

    OpenStruct.new(options).tap do |policy_record|
      policy_record.define_singleton_method :policy_class do
        klass
      end
    end
  end


  def initialize(user, record)
    fail Pundit::NotAuthorizedError, 'must be logged in' unless user

    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end

    protected

    def admin?
      user.admin?
    end
  end

  protected
  def admin?
    user.admin?
  end
end
