class Context
  def initialize(session)
    @session = session
  end
  
  def current_term
    @current_term ||= Term.where(:id => @session[:current_term]).first
  end
  
  def current_course
    @current_course ||= current_term.try(:course)
  end
end