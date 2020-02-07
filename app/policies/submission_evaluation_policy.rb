class SubmissionEvaluationPolicy < TermBasedPolicy
  def show?
    update?
  end

  def create?
    update? ## Comment create also asks for this permission
  end

  def destroy?
    update? ## Comment destroy also asks for this permission
  end

  def update?
    staff_permissions?(record.submission.term)
  end
end
