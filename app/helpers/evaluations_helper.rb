module EvaluationsHelper
  def evaluation_input(evaluation)
    content = if evaluation.rating.is_a? Ratings::FixedRating
      evaluation_button(evaluation)
    else
      evaluation_form(evaluation)
    end

    render("evaluations/evaluation_input", evaluation: evaluation, evaluation_input_content: content)
  end

  def evaluation_button(evaluation)
    value = if evaluation.value == 1
      0
    else
      1
    end

    classes =  ["#{evaluation_button_class(evaluation)}", "tiny", "button", "expand"]
    if evaluation.rating.description.present?
      classes << ["has-tip", "evaluation-tip"]
    end

    link_to evaluation.rating.title, evaluation_path(evaluation, evaluation: { value: value }), method: 'put', data: { remote: true }, class: classes.join(' '), 
      title: evaluation.rating.description.presence
    end

  def evaluation_form(evaluation)
    input_id = "evaluation_id_#{evaluation.id}"
    rating = evaluation.rating

    simple_form_for evaluation.becomes(Evaluation), url: evaluation_path(evaluation), remote: true, html: { class: 'evaluation-form' } do |f|
      f.input :value,
        label: rating.title,
        placeholder: "#{rating.min_value} upto #{rating.max_value} points",
        label_html: { title: (rating.description.presence || rating.title), for: input_id},
        input_html: { title: (rating.description.presence || rating.title), id: input_id}
    end
  end

  def evaluation_review_done_button(evaluation)
    link_to foundation_icon(:check), evaluation_path(evaluation, evaluation: { needs_review: 0 }), method: 'put', data: { remote: true }, class: "tiny button expand"
  end

  def evaluation_button_class(evaluation)
    if evaluation.value == 1
      # "secondary"
      'alert'
    else
      # "success"
      'secondary'
    end
  end

  def evaluation_id(evaluation)
    "evaluation_#{evaluation.id}"
  end
end
