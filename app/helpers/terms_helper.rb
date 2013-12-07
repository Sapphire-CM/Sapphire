module TermsHelper
  def set_lecturer_label
    if @term.lecturer.blank?
      "Set lecturer"
    else
      "Change lecturer"
    end
  end

  def student_grade_percentage(students, grade_distribution, grade)
    zeros = grade_distribution["0"] || 0

    percent = if students.count != zeros && grade != "0"
      (grade_distribution[grade] / (students.count - zeros).to_f * 100).round 1
    else
      0
    end
    "#{percent} %"
  end
end
