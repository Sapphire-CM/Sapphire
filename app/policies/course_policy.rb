class CoursePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if admin?
        Course.all
      else
        Course.associated_with(user).unlocked
      end
    end
  end

  def index?
    true
  end

  def create?
    admin?
  end

  def create_term?
    admin? || (
      record &&
      record.terms.any? &&
      user.lecturer_of_any_term_in_course?(record)
    )
  end

  def student_count?
    admin? || user.staff_of_course?(record)
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end
end
