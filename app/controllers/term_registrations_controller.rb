class TermRegistrationsController < ApplicationController
  def index
    @term_registrations = current_term.term_registrations
    
    if params[:view] == "mine"
      @term_registrations = @term_registrations.for_tutorial_group(current_term.tutorial_groups.where(:title => "T2").first)
    end
    
    
    @term_registrations = @term_registrations.with_students.with_tutorial_groups
    
    @term_registrations = @term_registrations.search(params[:q]) if params[:q]

    
    @grouped_term_registrations = @term_registrations.group_by {|term_registration| term_registration.tutorial_group}
  end
  
  def show
    @term_registration = TermRegistrationDecorator.decorate current_term.term_registrations.find(params[:id])
  end
end
