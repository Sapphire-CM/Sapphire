class SubmissionPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.staff_of_term?(record.exercise.term)
  end

  def show?
    user.admin? ||
    user.staff_of_term?(record.term) ||
    record.students.include?(user)
  end

  def submit?
    record.new_record? ? create? : update?
  end

  def directory?
    show?
  end

  def new?
    user.admin? ||
    user.associated_with_term?(record.exercise.term)
  end

  def edit?
    user.admin? ||
    user.staff_of_term?(record.exercise.term) ||
    record.students.include?(user)
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
    user.staff_of_term?(record.exercise.term) ||
    (
      record.exercise.enable_student_uploads? &&
      record.exercise.term.course.unlocked? &&
      record.exercise.before_late_deadline? &&
      record.visible_for_student?(user)
    )
  end

  def destroy?
    user.admin? ||
    user.staff_of_term?(record.exercise.term) ||
    (
      record.student_group.students.where(id: user.id).exists? &&
      record.exercise.term.course.unlocked? &&
      record.exercise.before_late_deadline?
    )
  end

  def catalog?
    user.admin? ||
    user.staff_of_term?(record.exercise.term) ||
    (
      record.exercise.enable_student_uploads? &&
      record.exercise.term.course.unlocked? &&
      record.exercise.before_late_deadline? &&
      record.visible_for_student?(user)
    )
  end

  def extract?
    user.admin? ||
    user.staff_of_term?(record.exercise.term) ||
    (
      record.exercise.enable_student_uploads? &&
      record.exercise.term.course.unlocked? &&
      record.exercise.before_late_deadline? &&
      record.visible_for_student?(user)
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
