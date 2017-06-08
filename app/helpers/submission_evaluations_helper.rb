module SubmissionEvaluationsHelper
  def submission_evaluation_pluralized_points(submission_evaluation)
    "#{submission_evaluation.evaluation_result} of #{pluralize submission_evaluation.submission.exercise.achievable_points, 'point'}"
  end
end
