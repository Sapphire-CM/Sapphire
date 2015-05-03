module TermsHelper
  def set_lecturer_label
    if @term.lecturer.blank?
      'Set lecturer'
    else
      'Change lecturer'
    end
  end
end
