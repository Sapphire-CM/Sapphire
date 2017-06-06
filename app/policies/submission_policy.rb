class SubmissionPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.staff_of_term?(record.exercise.term)
  end

  def show?
    user.admin? ||
    user.staff_of_term?(record.term) ||
    (
      user.student_of_term?(record.term) &&
      (
        record.students.include?(user) ||
        record.new_record?
      )
    )
  end

  def directory?
    show?
  end

  def new?
    user.admin? ||
    user.staff_of_term?(record.exercise.term) ||
    (
      record.exercise.term.associated_with?(user) &&
      record.exercise.term.course.unlocked?
    )
  end

  def create?
    user.admin? ||
    user.staff_of_term?(record.exercise.term) ||
    (
      record.exercise.enable_student_uploads? &&
      record.exercise.term.associated_with?(user) &&
      record.exercise.term.course.unlocked? &&
      record.exercise.before_late_deadline?
    )
  end

  def update?
    user.admin? ||
    user.staff_of_term?(record.exercise.term)
  end

  def destroy?
    user.admin? ||
    user.staff_of_term?(record.exercise.term) ||
    (
      record.visible_for_student?(user) &&
      record.exercise.term.course.unlocked? &&
      record.modifiable_by_students?
    )
  end


  def tree?
    viewable?
  end

  private
  def viewable?
    user.admin? ||
    user.staff_of_term?(record.exercise.term) ||
    record.visible_for_student?(user) ||
    record.new_record?
  end
end
