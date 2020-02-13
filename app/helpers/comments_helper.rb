module CommentsHelper 
  def evaluation_comment_button(evaluation)
    classes =  ["tiny", "button", "expand"]
    if evaluation.comments.present?
      classes << ["secondary"]
    end
    link_to "Comment", evaluation_comments_path(evaluation.becomes(Evaluation)), data: {remote: :true, "reveal-id" => "reveal_modal"}, class: classes.join(' ')
  end

  def upcast(commentable)
    if commentable.is_a?(Evaluation)
      commentable.becomes(Evaluation) 
    else
      commentable
    end
  end
end
