module Roles
  STUDENT = 'student'
  TUTOR = 'tutor'
  LECTURER = 'lecturer'

  ALL = [STUDENT, TUTOR, LECTURER].freeze
  STAFF = [TUTOR, LECTURER].freeze
end
