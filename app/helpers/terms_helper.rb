module TermsHelper
  def set_lecturer_label
    if @term.lecturer.blank?
      "Set lecturer"
    else
      "Change lecturer"
    end
  end

  def student_grade_percentage(term, grade)
    percent = if term.students.any?
      (term.grade_distribution[grade] / term.students.count.to_f * 100).round 1
    else
      0
    end
    "#{percent} %"
  end
end
