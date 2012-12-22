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
    "#{current_course.title} (#{current_term
.title})"
  end
end
