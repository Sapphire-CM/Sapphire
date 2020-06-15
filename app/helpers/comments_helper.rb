module CommentsHelper
  def evaluation_comment_button(evaluation)
    classes =  ["tiny", "button", "expand"]
    unless evaluation.explanations_comments.any?
      classes << ["secondary"]
    else
      classes << ["annotate"]
    end
    link_to "Explanation", evaluation_explanations_path(evaluation.becomes(Evaluation)), data: {remote: :true, "reveal-id" => "reveal_modal"}, class: classes.join(' '), id: dom_id(evaluation.becomes(Evaluation), 'comment_button')
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
