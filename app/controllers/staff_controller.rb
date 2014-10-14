class StaffController < ApplicationController
  include TermContext

  class StaffPolicyRecord < Struct.new(:user, :term)
    def policy_class
      StaffPolicy
    end
  end

  before_action :setup_form_context, only: [:new, :create]

  def index
    @term_registrations = current_term.term_registrations.staff.ordered_by_name
    authorize StaffPolicyRecord.new(current_account, current_term)
  end

  def new
    @term_registration = TermRegistration.new
    @term_registration.term = current_term
    @term_registration.role = Roles::LECTURER
    authorize(@term_registration)
  end

  def create
    @term_registration = TermRegistration.new(term_registration_params)
    @term_registration.term = current_term

    authorize(@term_registration)

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
    @accounts = Account.search(params[:q]).limit(100)
    @search_terms = params[:q]
    authorize(StaffPolicyRecord.new(current_account, current_term))
  end

  private
  def term_registration_params
    if params[:term_registration] && params[:term_registration][:role] == Roles::LECTURER
      params.require(:term_registration).permit(:account_id, :role)
    elsif params[:term_registration] && params[:term_registration][:role] == Roles::TUTOR
      params.require(:term_registration).permit(:account_id, :role, :tutorial_group_id)
    end
  end

  def setup_form_context
    @tutorial_groups = current_term.tutorial_groups
  end
end
