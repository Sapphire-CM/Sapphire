class SubmissionEvaluationPolicy < TermBasedPolicy
  def index?
    update?
  end

  def show?
    update?
  end

  def create?
    update?
  end

  def update?
    update?
  end

  def destroy?
    update?
  end

  def update?
    staff_permissions?(record.submission.term)
  end
end
