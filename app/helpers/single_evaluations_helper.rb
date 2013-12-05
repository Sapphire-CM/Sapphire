#encoding: utf-8

module SingleEvaluationsHelper
  def single_evaluation_input(evaluation)
    rating = evaluation.rating

    if rating.is_a? BinaryRating
      css_class = if evaluation.value == 1
        # "secondary"
        "alert"
      else
        # "success"
        "secondary"
      end

      link_to rating.title, single_evaluation_path(evaluation), id: single_evaluation_button_id(evaluation), method: "put", data: {remote: true}, class: "#{css_class} tiny button expand"
    else
      simple_form_for evaluation.becomes(Evaluation), url: single_evaluation_path(evaluation), remote: true, html: {class: "single-evaluation-form"} do |f|
        f.input :value, label: rating.title
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
    css_class = "small secondary button expand" + (submission.blank? ? " disabled" : "")
    link_to "« Prev", single_evaluation_submission_path(submission), class: css_class
  end

  def next_single_evaluation_button(submission)
    css_class = "small button expand" + (submission.blank? ? " disabled" : "")
    link_to "Next »", single_evaluation_submission_path(submission), class: css_class
  end

  def single_evaluation_pluralized_points(points)
   pluralize @submission.submission_evaluation.evaluation_result, "point"
  end

  def single_evaluation_evaluation_group_id(evaluation_group)
    "evaluation_group_#{evaluation_group.id}"
  end

  def single_evaluation_button_id(evaluation)
    "evaluation_#{evaluation.id}"
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
