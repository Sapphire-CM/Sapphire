class DiskUsagePolicy < PunditBasePolicy

def render_exercise?
	user.present?
end

end
