class TutorialGroupsController < TermResourceController

  # index action not needed

  def show
    @tutorial_group = current_term.tutorial_groups.find(params[:id])

    # TODO: @submissions = @tutorial_group.submissions.includes(:student, :exercise, :submission_evaluation).order(:submitted_at)

    if @tutorial_group.tutor.blank?
      render alert: 'You have not set a tutor yet!'
    end
  end

  def new
    @tutorial_group = current_term.tutorial_groups.new
  end

  def create
    @tutorial_group = current_term.tutorial_groups.new(params[:tutorial_group])

    if @tutorial_group.save
      redirect_to term_tutorial_group_path(current_term, @tutorial_group), notice: "Tutorial group successfully created."
    else
      render :new
    end
  end

  def edit
    @tutorial_group = current_term.tutorial_groups.find(params[:id])
  end

  def update
    @tutorial_group = current_term.tutorial_groups.find(params[:id])

    if @tutorial_group.update_attributes(params[:tutorial_group])
      redirect_to term_tutorial_group_path(current_term, @tutorial_group), notice: "Tutorial group successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @tutorial_group = current_term.tutorial_groups.find(params[:id])
    @tutorial_group.destroy
    redirect_to term_path(current_term), notice: "Tutorial group successfully deleted."
  end

  def new_tutor_registration
    @tutorial_group = current_term.tutorial_groups.find(params[:tutorial_group_id])
    @accounts = Account.scoped.page(params[:page]).per(50)
    @accounts = @accounts.search(params[:q]) if params[:q].present?
  end

  def create_tutor_registration
    @tutorial_group = current_term.tutorial_groups.find(params[:tutorial_group_id])
    @account = Account.find(params[:account_id])

    registration = TutorRegistration.find_or_initialize_by_tutorial_group_id(@tutorial_group.id)
    registration.tutor = @account

    save_registration_and_redirect registration
  end

  def clear_tutor_registration
    @tutorial_group = current_term.tutorial_groups.find(params[:tutorial_group_id])
    @tutorial_group.tutor_registration.destroy

    redirect_to term_tutorial_group_path(current_term, @tutorial_group), notice: "Tutor registration successfully cleared!"
  end

  private

  def save_registration_and_redirect(registration)
    registration.registered_at = DateTime.now
    if registration.save
      redirect_to term_tutorial_group_path(current_term, @tutorial_group), notice: "New registration successfully added."
    else
      redirect_to term_tutorial_group_path(current_term, @tutorial_group), alert: "Registration failed!"
    end
  end

end
