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
    user.lecturer_of_term?(record.exercise.term) ||
    (
      record.new_record? ||
      record.student_group && (
        user.tutor_of_tutorial_group?(record.student_group.tutorial_group) ||
        record.student_group.students.where(id: user.id).exists?
      )
    )
  end

  def create?
    user.admin? ||
    (
      record.exercise.term.associated_with?(user) &&
      record.exercise.term.course.unlocked? &&
      (record.exercise.late_deadline.present? ? Time.now <= record.exercise.late_deadline : true)
    )
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term) ||
    user.tutor_of_tutorial_group?(record.student_group.tutorial_group) ||
    (
      record.student_group.students.where(id: user.id).exists? &&
      record.exercise.term.course.unlocked? &&
      (record.exercise.late_deadline.present? ? Time.now <= record.exercise.late_deadline : true)
    )
  end
end
