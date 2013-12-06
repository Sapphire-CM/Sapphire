module TermsHelper
  def set_lecturer_label
    if @term.lecturer.blank?
      "Set lecturer"
    else
      "Change lecturer"
    end
  end

  def student_grade_percentage(students, grade_distribution, grade)
    percent = if students.any?
      (grade_distribution[grade] / students.count.to_f * 100).round 1
    else
      0
    end
    "#{percent} %"
  end
end
