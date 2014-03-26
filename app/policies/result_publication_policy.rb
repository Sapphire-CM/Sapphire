class ResultPublicationPolicy < PunditBasePolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def index?
    user.admin?
  end

  def update?
    user.admin?
  end
end
