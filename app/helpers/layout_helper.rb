module LayoutHelper
  def title(title, show_title = true)
    content_for :title, title
    @show_title = show_title
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
    end
    
    classes.join(" ")
  end

  
  def course_term_title(course, term)
    "#{course.title}: #{term.title}"
  end
  
  # Todo: scope this appropriatly for the current_user
  def navigation_context_selector
    terms = Term.with_courses
    terms = terms.where {id != my{current_term.id} } if term_context?
    
    render "application/navigation_context_selector", :terms => terms.all
  end
end
