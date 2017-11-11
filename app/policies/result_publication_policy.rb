class ResultPublicationPolicy < TermBasedPolicy
  def index?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def publish?
    update?
  end

  def conceal?
    update?
  end

  def publish_all?
    update?
  end

  def conceal_all?
    update?
  end
end
