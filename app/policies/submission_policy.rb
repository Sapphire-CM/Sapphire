class SubmissionPolicy < TermBasedPolicy
  def index?
    staff_permissions?
  end

  def show?
    staff_permissions? ||
    (
      student? && (
        record.students.include?(user) ||
        record.new_record?
      )
    )
  end

  def create?
    staff_permissions? ||
    (
      student? &&
      record.exercise.enable_student_uploads? &&
      record.exercise.term.course.unlocked? &&
      record.exercise.before_late_deadline?
    )
  end

  def update?
    staff_permissions? ||
    modifiable?
  end

  def destroy?
    staff_permissions? ||
    modifiable?
  end

  def directory?
    show?
  end

  def tree?
    staff_permissions? ||
    record.visible_for_student?(user) ||
    record.new_record?
  end

  private
  def modifiable?
    record.visible_for_student?(user) &&
    record.modifiable_by_students? &&
    record.exercise.term.course.unlocked?
  end
end
