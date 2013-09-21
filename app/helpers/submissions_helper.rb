module SubmissionsHelper
  def submission_title(submission)
    exercise = submission.exercise
    titles = []
    if submission.student_group.present?
      sub_title =
      if exercise.group_submission?
        creator = submission.student_group
      else
        student = submission.student_group.students.first
        creator = "#{student.fullname} (#{student.matriculum_number})"
      end
    else
      creator = "unknown author"
    end


    "Submission of #{creator}"
  end
end
