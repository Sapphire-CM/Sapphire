module CommentsHelper 
  def evaluation_comment_button(evaluation)
    classes =  ["tiny", "button", "expand"]
    unless evaluation.explanations_comments.any?
      classes << ["secondary"]
    end
    link_to "Explanation", evaluation_explanations_path(evaluation.becomes(Evaluation)), data: {remote: :true, "reveal-id" => "reveal_modal"}, class: classes.join(' '), id: dom_id(evaluation.becomes(Evaluation), 'comment_button')
  end
end
