module PointsOverviewHelper
  def exercise_result(tutorial_group, student, exercise)
    if tutorial_group.student_has_submission_for_exercise?(student, exercise)
      submission_evaluation = student.submission_for_exercise(exercise).first.submission_evaluation

      if submission_evaluation.plagiarized
        content_tag :span, submission_evaluation.evaluation_result, class: 'plag'
      else
        submission_evaluation.evaluation_result
      end
    else
      "na"
    end
  end

  def points_for_exercise(tutorial_group, student, exercise)
    result = 0
    if tutorial_group.student_has_submission_for_exercise?(student, exercise)
      submission_evaluation = student.submission_for_exercise(exercise).first.submission_evaluation
      result = submission_evaluation.evaluation_result
    end
    result
  end

  def total_points(term, student)
    if term.participated? student
      student.points_for_term term
    else
      "na"
    end
  end

  def final_grade(term, student)
    if term.participated? student
      student.grade_for_term term
    else
      "0"
    end
  end
end
