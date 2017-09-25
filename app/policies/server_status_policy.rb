class ServerStatusPolicy < PunditBasePolicy
  def index?
    user.admin?
  end
end