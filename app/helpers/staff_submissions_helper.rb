module StaffSubmissionsHelper
  def staff_submission_title(submission)
    if submission.student_group.present?
      "Submission of #{submission.student_group.title}"
    else
      "Submission of unknown #{submission.exercise.solitary_submission? ? "student" : "group"}"
    end
  end
end
