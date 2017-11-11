class CoursePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        Course.all.includes(:terms)
      else
        Course.associated_with(user).includes(:terms).unlocked
      end
    end
  end

  def index?
    user.present?
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def create_term?
    user.admin? || (
      record &&
      record.terms.any? &&
      user.lecturer_of_any_term_in_course?(record)
    )
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end
