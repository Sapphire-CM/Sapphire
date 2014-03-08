class StudentGroupPolicy < PunditBasePolicy
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
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

  def new_student_registration?
    user.admin?
  end

  def create_student_registration?
    user.admin?
  end
end
