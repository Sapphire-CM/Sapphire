class DiskUsagePolicy < PunditBasePolicy
  
  def index?
    user.admin? ||
    user.lecturer_of_term?(record)
  end
  
end
