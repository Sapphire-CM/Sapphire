class ContextController < ApplicationController
  def index
    @terms = Term.with_courses
    
    @grouped_terms = @terms.group_by(&:course)
  end
  
  def update
    session[:context] ||= {}
    session[:context][:current_term] = params[:id]
    redirect_to :back, :notice => "You switched to #{current_course.title} (#{current_term.title})"
  end
end
