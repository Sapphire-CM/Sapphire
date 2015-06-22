class ResultPublicationPolicy < PunditBasePolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def index?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def publish_all?
    update?
  end

  def conceal_all?
    update?
  end
end
