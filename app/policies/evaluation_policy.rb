class EvaluationPolicy < TermBasedPolicy
  def update?
    staff_permissions?(record.evaluation_group.submission_evaluation.submission.term)
  end

  def index?
    show?
  end

  def show?
    update? || student?(record.evaluation_group.submission_evaluation.submission.term)
  end

  def create?
    update?
  end

  def destroy?
    update?
  end
end
