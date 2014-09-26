class TutorialGroupPolicy < PunditBasePolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def index?
    user.admin? ||
    user.lecturer_of_term?(record.subject) ||
    user.tutor_of_term?(record.subject) ||
    user.tutor_of_any_tutorial_group_in_term?(record.subject)
  end

  def show?
    user.admin? ||
    user.lecturer_of_term?(record.term) ||
    user.tutor_of_term?(record) ||
    user.tutor_of_any_tutorial_group_in_term?(record.term)
  end

  def new?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def create?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def edit?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def destroy?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def points_overview?
    user.admin? ||
    user.lecturer_of_term?(record.term) ||
    user.tutor_of_term?(record) ||
    user.tutor_of_any_tutorial_group_in_term?(record.term)
  end
end
