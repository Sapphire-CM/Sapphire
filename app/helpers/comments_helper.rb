module CommentsHelper
  def internal_comment_button(commentable)
    title = ""
    classes =  ["small", "button"]
    unless commentable.internal_notes_comments.any?
      title = "Add Internal Note"
    else
      title = "Interal Notes #{badge(commentable.internal_notes_comments.count)}".html_safe
      classes << ["internal"]
    end
    link_to title, submission_evaluation_internal_notes_path(commentable), class: classes.join(' '), remote: true, data: {"reveal-id" => "reveal_modal"}, id: dom_id(commentable, 'internal_notes_button')
  end

  def feedback_comment_button(commentable)
    title = ""
    classes =  ["small", "button"]
    unless commentable.feedback_comments.any?
      title = "Add Feedback"
    else
      title = "Feedback #{badge(commentable.feedback_comments.count)}".html_safe
      classes << ["annotate"]
    end

    link_to title, submission_evaluation_feedback_index_path(commentable), class: classes.join(' '), remote: true, data: {"reveal-id" => "reveal_modal"}, id: dom_id(commentable, 'feedback_button')
  end

  def evaluation_comment_button(evaluation)
    classes =  ["tiny", "button", "expand"]
    unless evaluation.explanations_comments.any?
      classes << ["secondary"]
      title = "Explanations"
    else
      classes << ["annotate"]
      title = "Explanations #{badge(evaluation.explanations_comments.count)}".html_safe
    end
    link_to title, evaluation_explanations_path(evaluation.becomes(Evaluation)), data: {remote: :true, "reveal-id" => "reveal_modal"}, class: classes.join(' '), id: dom_id(evaluation.becomes(Evaluation), 'comment_button')
  end

  def humanized_comment_type(comment)
    if comment.is_a?(Comment)
      comment.name.singularize.humanize
    elsif comment.is_a?(String)
      comment.singularize.humanize
    end
  end

  def comment_heading(comment)
    case comment.name
      when 'feedback'
        "#{humanized_comment_type(comment)} from <strong>#{comment.account.fullname}</strong>:".html_safe
      when 'internal_notes', 'explanations'
        "#{humanized_comment_type(comment)} by <strong>#{comment.account.fullname}</strong>:".html_safe
    end
  end
end
