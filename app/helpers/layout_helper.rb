module LayoutHelper
  def title(title, show_title = true)
    content_for :title, title
    @show_title = show_title
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
  
  def current_course_term_title
    if current_term && current_course
      course_term_title(current_course, current_term)
    else
      "-- no course selected --"
    end
  end
  
  def course_term_title(course, term)
    "#{course.title} (#{term.title})"
  end
  
  # Todo: scope this appropriatly for the current_user
  def navigation_context_selector
    terms = Term.where {id != my{current_term.id} }. with_courses.all 
    render "application/navigation_context_selector", :terms => terms
  end
end
