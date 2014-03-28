class SubmissionPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term) ||
    user.tutor_of_tutorial_group?(record.tutorial_group)
  end

  def show?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term) ||
    (
      record.student_group && (
        user.tutor_of_tutorial_group?(record.student_group.tutorial_group) ||
        record.student_group.students.where(id: user.id).exists?
      )
    )
  end

  def create?
    user.admin? ||
    record.exercise.term.associated_with?(user)
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term) ||
    user.tutor_of_tutorial_group?(record.student_group.tutorial_group) ||
    record.student_group.students.where(id: user.id).exists?
  end
end
