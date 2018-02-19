module StaffHelper
  def staff_role_options
    Roles::STAFF.map do |role|
      [role.humanize, role]
    end
  end
end
