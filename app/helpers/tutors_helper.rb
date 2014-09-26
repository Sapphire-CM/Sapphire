module TutorsHelper
  def tutor_names(tutors)
    if tutors.present? && tutors.any?
      tutors.map do |tutor|
        tutor.fullname
      end.join(", ")
    else
      "(no tutor)"
    end
  end
end
