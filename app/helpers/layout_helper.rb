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
    course_term_title(current_course, current_term)
  end
  
  def course_term_title(course, term)
    "#{course.title} (#{term.title})"
  end
  
  # Todo: scope this appropriatly for the current_user
  def navigation_context_selector
    lis = ""
    Term.with_courses.each do |term|
      lis << "<li>#{link_to(course_term_title(term.course, term), context_path(term), :method => :put).html_safe}</li>"
    end
    lis.html_safe
  end
end
