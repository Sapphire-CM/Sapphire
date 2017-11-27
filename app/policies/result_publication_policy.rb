class ResultPublicationPolicy < TermBasedPolicy
  def index?
    lecturer_permissions?
  end

  def update?
    lecturer_permissions?
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
