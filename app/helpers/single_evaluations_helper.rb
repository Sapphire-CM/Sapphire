module SingleEvaluationsHelper
  def previous_single_evaluation_button(submission)
    css_class = 'small secondary button expand' + (submission.blank? ? ' disabled' : '')
    link_to '« Prev', single_evaluation_submission_path(scoping_options(submission)), class: css_class
  end

  def next_single_evaluation_button(submission)
    css_class = 'small button expand' + (submission.blank? ? ' disabled' : '')
    link_to 'Next »', single_evaluation_submission_path(scoping_options(submission)), class: css_class
  end

  def scoping_options(submission)
    options = {}
    options[:id] = submission.id if submission.present?
    %i(submission_scope tutorial_group_id).each do |param|
      options[param] = params[param] if params[param].present?
    end
    options
  end

  def single_evaluation_pluralized_points(_points)
    "#{@submission.submission_evaluation.evaluation_result} of #{pluralize @submission.exercise.achievable_points, 'point'}"
  end

  def single_evaluation_asset_name(submission_asset)
    asset_name = File.basename(submission_asset.file.to_s)
    asset_name.prepend "#{submission_asset.path}/" if submission_asset.path.presence
    shorten(asset_name, 60)
  end

  private

  def single_evaluation_submission_path(submission)
    if submission.present?
      single_evaluation_path(submission)
    else
      exercise_submissions_path(@submission.exercise)
    end
  end
end
