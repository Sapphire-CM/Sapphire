class TermPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.associated_with(user)
      end
    end
  end

  def show?
    user.admin? ||
    record.associated_with?(user)
  end

  def new?
    user.admin? ||
    user.lecturer_of_any_term_in_course?(record.course)
  end

  def create?
    user.admin? || (
      record.course &&
      record.course.terms.any? &&
      user.lecturer_of_any_term_in_course?(record.course)
    )
  end

  def edit?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def destroy?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def points_overview?
    user.admin? ||
    user.staff_of_term?(record)
  end

  def student?
    user.student_of_term?(record)
  end

  def tutor?
    user.tutor_of_term?(record)
  end

  def staff?
    user.staff_of_term?(record)
  end
end
