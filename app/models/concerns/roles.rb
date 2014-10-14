module Roles
  STUDENT = "student"
  TUTOR = "tutor"
  LECTURER = "lecturer"

  ALL = [STUDENT, TUTOR, LECTURER].freeze
  STAFF = [TUTOR, LECTURER].freeze

  ALL.each do |role|
    define_method "#{role}?" do
      self.role.to_s == role.to_s
    end
  end

  def staff?
    STAFF.include? self.role.to_s
  end
end