class SubmissionPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term) ||
    if record.tutorial_group.present?
      user.tutor_of_tutorial_group?(record.tutorial_group)
    else
      false
    end
  end

  def show?
    user.admin? ||
    user.associated_with_term?(record.exercise.term)
  end

  def submit?
    record.new_record? ? create? : update?
  end

  def new?
    user.admin? ||
    user.associated_with_term?(record.exercise.term)
  end

  def edit?
    user.admin? ||
    user.staff_of_term?(record.exercise.term)
  end

  def create?
    user.admin? ||
    user.staff_of_term?(record.exercise.term) ||
    (
      record.exercise.enable_student_uploads? &&
      record.exercise.term.associated_with?(user) &&
      record.exercise.term.course.unlocked? &&
      (record.exercise.late_deadline.present? ? Time.now <= record.exercise.late_deadline : true)
    )
  end

  def update?
    user.admin? ||
    user.staff_of_term?(record.exercise.term) ||
    (
      record.exercise.enable_student_uploads? &&
      record.student_group.students.where(id: user.id).exists? &&
      record.exercise.term.course.unlocked? &&
      (record.exercise.late_deadline.present? ? Time.now <= record.exercise.late_deadline : true)
    )
  end

  def destroy?
    user.admin? ||
    user.staff_of_term?(record.exercise.term) ||
    (
      record.student_group.students.where(id: user.id).exists? &&
      record.exercise.term.course.unlocked? &&
      (record.exercise.late_deadline.present? ? Time.now <= record.exercise.late_deadline : true)
    )
  end
end
