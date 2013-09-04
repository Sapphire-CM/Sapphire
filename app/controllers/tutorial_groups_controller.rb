class TutorialGroupsController < ApplicationController
  before_action :set_context, only: [:show, :edit, :update, :destroy, :new_tutor_registration, :create_tutor_registration, :clear_tutor_registration]

  def show
    if @tutorial_group.tutor.blank?
      render alert: 'You have not set a tutor yet!'
    end
  end

  def new
    @tutorial_group = TutorialGroups.new
    @tutorial_group.term = Term.find(params[:term_id])
  end

  def create
    @tutorial_group = TutorialGroup.new(params[:tutorial_group])

    if @tutorial_group.save
      redirect_to @tutorial_group, notice: "Tutorial group successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @tutorial_group.update_attributes(params[:tutorial_group])
      redirect_to @tutorial_group, notice: "Tutorial group successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @tutorial_group.destroy
    redirect_to @term, notice: "Tutorial group successfully deleted."
  end

  def new_tutor_registration
    @accounts = Account.scoped.page(params[:page]).per(50)
    @accounts = @accounts.search(params[:q]) if params[:q].present?
  end

  def create_tutor_registration
    @account = Account.find(params[:account_id])

    registration = TutorRegistration.find_or_initialize_by_tutorial_group_id(@tutorial_group.id)
    registration.tutor = @account

    save_registration_and_redirect registration
  end

  def clear_tutor_registration
    @tutorial_group.tutor_registration.destroy
    redirect_to tutorial_group_path(@tutorial_group), notice: "Tutor registration successfully cleared!"
  end

  private
    def set_context
      @tutorial_group = TutorialGroup.find(params[:id] || params[:tutorial_group_id])
      @term = @tutorial_group.term
    end

    def save_registration_and_redirect(registration)
      registration.registered_at = DateTime.now
      if registration.save
        redirect_to tutorial_group_path(@tutorial_group), notice: "New registration successfully added."
      else
        redirect_to tutorial_group_path(@tutorial_group), alert: "Registration failed!"
      end
    end

end
