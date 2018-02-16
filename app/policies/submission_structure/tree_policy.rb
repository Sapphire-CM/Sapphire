class SubmissionStructure::TreePolicy < TermBasedPolicy
  def show?
    read_permissions?
  end

  def directory?
    show?
  end

  def destroy?
    write_permissions?
  end

  private

  def read_permissions?
    staff_permissions?(term) ||
    (
      student?(term) && (
        submission.students.include?(user) ||
        submission.new_record?
      )
    )
  end

  def write_permissions?
    staff_permissions?(term) || modifiable?
  end

  def modifiable?
    submission.visible_for_student?(user) &&
    submission.modifiable_by_students? &&
    term.course.unlocked?
  end

  def submission
    record.submission
  end

  def term
    submission.term
  end
end
