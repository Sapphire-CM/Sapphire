class TermPolicy < PunditBasePolicy
  def show?
    user.admin? ||
    user.lecturer_of_term?(record) ||
    user.tutor_of_term?(record)
  end

  def new?
    user.admin? ||
    user.lecturer_of_any_term_in_course?(record.course)
  end

  def create?
    user.admin? ||
    user.lecturer_of_any_term_in_course?(record.course)
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

  def new_lecturer_registration?
    user.admin? ||
    user.lecturer_of_any_term_in_course?(record.course)
  end

  def create_lecturer_registration?
    user.admin? ||
    user.lecturer_of_any_term_in_course?(record.course)
  end

  def clear_lecturer_registration?
    user.admin? ||
    user.lecturer_of_any_term_in_course?(record.course)
  end

  def grading_scale?
    user.admin? ||
    user.lecturer_of_term?(record) ||
    user.tutor_of_term?(record)
  end

  def update_grading_scale?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def points_overview?
    user.admin? ||
    user.lecturer_of_term?(record) ||
    user.tutor_of_term?(record)
  end
end
