module StaffSubmissionsHelper
  def staff_submission_title(submission)
    if submission.exercise.solitary_submission?
      "Submission of #{submission_author(submission)}"
    else
      if submission.student_group.present?
        "Submission of #{submission.student_group.title}"
      else
        "Submission of unknown student group"
      end
    end

  end
end
