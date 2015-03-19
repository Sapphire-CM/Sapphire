module TutorsHelper
  def tutor_names(tutors)
    if tutors.present? && tutors.any?
      tutors.map(&:fullname).join(', ')
    else
      '(no tutor)'
    end
  end
end
