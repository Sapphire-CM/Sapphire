module SingleEvaluationsHelper
  def single_evaluation_input(evaluation)
    rating = evaluation.rating

    if rating.is_a? Ratings::BinaryRating
      css_class = if evaluation.value == 1
        # "secondary"
        'alert'
      else
        # "success"
        'secondary'
      end

      link_to rating.title, single_evaluation_path(evaluation), id: single_evaluation_button_id(evaluation), method: 'put', data: { remote: true }, class: "#{css_class} tiny button expand"
    else
      input_id = "evaluation_id_#{evaluation.id}"
      simple_form_for evaluation.becomes(Evaluation), url: single_evaluation_path(evaluation), remote: true, html: { class: 'single-evaluation-form' } do |f|
        f.input :value,
          label: rating.title,
          placeholder: "#{rating.min_value} upto #{rating.max_value} points",
          label_html: { title: (rating.description.presence || rating.title), for: input_id},
          input_html: { title: (rating.description.presence || rating.title), id: input_id}
      end
    end
  end

  def single_evaluation_evaluation_group_title(evaluation_group)
    title = evaluation_group.rating_group.title
    title += if evaluation_group.rating_group.points != 0
      " (#{evaluation_group.points}/#{evaluation_group.rating_group.points})"
    else
      " (#{evaluation_group.points})"
    end
    title
  end

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

  def single_evaluation_evaluation_group_id(evaluation_group)
    "evaluation_group_#{evaluation_group.id}"
  end

  def single_evaluation_button_id(evaluation)
    "evaluation_#{evaluation.id}"
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
