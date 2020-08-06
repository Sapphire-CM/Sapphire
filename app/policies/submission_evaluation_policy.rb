class SubmissionEvaluationPolicy < TermBasedPolicy
  def index?
    modify?
  end

  def show?
    modify?
  end

  def create?
    modify?
  end

  def update?
    modify?
  end

  def destroy?
    modify?
  end

  private
  def modify?
    staff_permissions?(record.submission.term)
  end
end
