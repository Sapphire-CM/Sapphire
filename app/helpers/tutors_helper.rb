module TutorsHelper
  def tutor_names(tutors)
    if tutors.present? && tutors.any?
      tutors.map(&:fullname).to_sentence
    else
      '(no tutor)'
    end
  end
end
