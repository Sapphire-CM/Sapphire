module TutorsHelper
  def tutor_name(tutor)
    unless tutor.nil?
      tutor.fullname
    else
      "(no tutor)"
    end
  end
end
