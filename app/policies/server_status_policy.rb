class ServerStatusPolicy < PunditBasePolicy

	def index?
		user.admin? ||
		user.staff_of_term?(record)
	end
end