class EvaluationPolicy < TermBasedPolicy
  def update?
    modify?
  end

  def index?
    modify? || student_permission?
  end

  def show?
    modify? || student_permission?
  end

  def create?
    modify?
  end

  def destroy?
    modify?
  end

  private
  def modify?
    staff_permissions?(record.evaluation_group.submission_evaluation.submission.term)
  end

  def student_permission?
    student?(record.evaluation_group.submission_evaluation.submission.term)
  end
end
