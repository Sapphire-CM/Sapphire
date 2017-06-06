module EvaluationGroupsHelper
  def evaluation_group_element_id(evaluation_group)
    "evaluation-group-#{evaluation_group.id}"
  end

  def evaluation_group_label(evaluation_group, css_class: nil)
    if evaluation_group.needs_review?
      icon = :alert
      label_class = "alert"
    else
      icon = case evaluation_group.status.to_sym
      when :pending then :clock
      when :done then :check
      end

      label_class = case evaluation_group.status.to_sym
      when :done then :success
      end
    end

    label_class = "#{label_class} #{css_class}" unless css_class.nil?

    content_tag(:span, foundation_icon(icon), class: "label radius #{label_class}")
  end

  def evaluation_group_should_collapse?(evaluation_group)
    evaluation_group.done? && !evaluation_group.needs_review?
  end

  def evaluation_group_title(evaluation_group)
    title = evaluation_group.rating_group.title
    title += if evaluation_group.rating_group.points != 0
      " (#{evaluation_group.points}/#{evaluation_group.rating_group.points})"
    else
      " (#{evaluation_group.points})"
    end
    title
  end

  def evaluation_group_bubble(evaluation_group)
    link_to evaluation_group_label(evaluation_group, css_class: "round"), "##{evaluation_group_anchor_id(evaluation_group)}", title: evaluation_group_title(evaluation_group)
  end

  def evaluation_group_title_id(evaluation_group)
    "evaluation-group-title-#{evaluation_group.id}"
  end

  def evaluation_group_label_id(evaluation_group)
    "evaluation-group-label-#{evaluation_group.id}"
  end

  def evaluation_group_anchor_id(evaluation_group)
    "eg-#{evaluation_group.title.parameterize}-#{evaluation_group.id}"
  end

  def evaluation_group_bubble_id(evaluation_group)
    "evaluation-group-bubble-#{evaluation_group.id}"
  end
end
