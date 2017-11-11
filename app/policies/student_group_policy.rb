class StudentGroupPolicy < TermBasedPolicy
  def index?
    user.admin? || user.staff_of_term?(record.term)
  end

  def show?
    user.admin? || user.staff_of_term?(record.term)
  end

  def create?
    authorized?(record.term)
  end

  def update?
    authorized?
  end

  def destroy?
    authorized?
  end

  def search_students?
    authorized?(record.term)
  end

  private

  def authorized?(r = nil)
    user.admin? || if !r.nil?
      user.lecturer_of_term?(r)
    elsif record.term.present?
      user.lecturer_of_term?(record.term)
    end
  end
end
