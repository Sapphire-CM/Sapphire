class SubmissionAssetPolicy < PunditBasePolicy
  def show?
    user.admin?
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
  end
end
