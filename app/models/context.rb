class Context
  def initialize(session)
    @session = session
  end
  
  def current_term
    # Term.active.first worx for now - but must be fixed later!
    @current_term ||= Term.where(:id => @session[:current_term]).first || Term.active
  end
  
  def current_course
    @current_course ||= current_term.course
  end
end