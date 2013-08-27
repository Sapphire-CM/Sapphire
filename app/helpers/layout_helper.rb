module LayoutHelper
  def title(title, subtitle=nil)
    content_for :title, title
    @show_title = true

    if subtitle.is_a? String
      content_for :subtitle, subtitle
    elsif subtitle.is_a? FalseClass
      @show_title = false
    end
  end

  def link_to_current_term
    if term_context?
      link_to course_term_title(current_course, current_term), course_term_path(current_course, current_term)
    else
      # Todo: change to not using a link here!
      link_to "<em>-- no term selected --</em>".html_safe, '#'
    end
  end

  def sidebar(text = "", &block)
    if block_given?
      content_for :sidebar, capture(&block)
    else
      content_for :sidebar, text
    end
  end

  def flash_class_for(key)
    classes = ["alert-box"]

    if key == :notice
      classes << "success"
    elsif key == :error || key == :alert
      classes << "alert"
    elsif key == :secondary
      classes << "secondary"
    end

    classes.join(" ")
  end


  def course_term_title(course, term)
    "#{course.title}: #{term.title}"
  end

  # Todo: scope this appropriatly for the current_user
  def navigation_context_selector
    terms = Term
    terms = terms.where {id != my{current_term.id} } if term_context?

    render "application/navigation_context_selector", terms: terms.all
  end


  def side_navigation_item(title, path, options = {})
    classes = []

    if options[:active].nil?
      classes << "active" if current_page?(path)
    else
      classes << "active" if options[:active]
      options = options.except(:active)
    end

    content_tag :li, link_to(title, path, options), class: classes.join(" ")
  end

  def rating_points_description(rating)
    if rating.is_a? BinaryNumberRating
      if rating.value.abs == 1
        "#{rating.value} point"
      else
        "#{rating.value} points"
      end
    elsif rating.is_a? BinaryPercentRating
      "#{rating.value} %"
    elsif rating.is_a? ValueNumberRating
      "#{rating.min_value} to #{rating.max_value} points"
    elsif rating.is_a? ValuePercentRating
      "#{rating.min_value} to #{rating.max_value} %"
    end
  end

  def rating_group_full_title(rating_group)
    full_title = rating_group.title
    full_title += ": #{rating_group_subtitle_points(rating_group)}" if not rating_group.global

    full_title
  end

  def rating_group_subtitle_points(rating_group)
    subtitle = "#{pluralize rating_group.points, "point"}"
    subtitle += " (#{rating_group.min_points} ... #{rating_group.max_points})" if rating_group.enable_range_points

    subtitle
  end

  def foundation_icon(icon)
    "<i class='fi-#{icon.to_s.dasherize}'></i>".html_safe
  end

end
