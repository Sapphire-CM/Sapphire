class StaffController < ApplicationController
  include TermContext

  before_action :setup_form_context, only: [:new, :create]

  def index
    @term_registrations = current_term.term_registrations.staff.ordered_by_name
    authorize StaffPolicy.with current_term
  end

  def new
    @term_registration = TermRegistration.new
    authorize @term_registration

    @term_registration.term = current_term
    @term_registration.role = Roles::LECTURER
  end

  def create
    @term_registration = current_term.term_registrations.new(term_registration_params)
    authorize @term_registration

    if @term_registration.save
      redirect_to term_staff_index_path(current_term)
    else
      render :new
    end
  end

  def destroy
    @term_registration = current_term.term_registrations.find(params[:id])
    authorize @term_registration

    @term_registration.destroy
    redirect_to term_staff_index_path(current_term)
  end

  def search
    authorize StaffPolicy.with current_term

    @accounts = Account.search(params[:q]).limit(100)
    @search_terms = params[:q]
  end

  private

  def term_registration_params
    permitted_params = [:account_id, :role]
    permitted_params << :tutorial_group_id if params[:term_registration][:role] == Roles::TUTOR
    params.require(:term_registration).permit(permitted_params)
  end

  def setup_form_context
    @tutorial_groups = current_term.tutorial_groups
  end
end
