class StudentGroupPolicy < PunditBasePolicy
  def index?
    user.admin? || user.staff_of_term?(record)
  end

  def show?
    user.admin? || user.staff_of_term?(record.term)
  end

  def new?
    create?
  end

  def create?
    authorized?(record)
  end

  def edit?
    update?
  end

  def update?
    authorized?
  end

  def destroy?
    authorized?
  end

  def search_students?
    authorized?(record)
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
