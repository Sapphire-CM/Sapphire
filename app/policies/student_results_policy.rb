class StudentResultsPolicy < TermBasedPolicy
  def index?
    student?
  end

  def show?
    record.submission_review.published? &&
    record.submission_review.term_registration.account == user
  end
end
