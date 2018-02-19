class StudentsController < ApplicationController
  include TermContext

  def index
    authorize StudentsPolicy.term_policy_record(current_term)

    @term_registrations = students_scope.includes(:account, :exercise_registrations, :term, tutorial_group: :tutor_accounts)
    @grading_scale_service = GradingScaleService.new(current_term)
  end

  def show
    set_term_registration
    set_term_review

    authorize StudentsPolicy.term_policy_record(current_term)
  end

  def new
    @term_registration = TermRegistration.new
    authorize @term_registration
  end

  def create
    @term_registration = TermRegistration.new(new_term_registration_params)
    @term_registration.term = @term
    @term_registration.role = :student

    authorize @term_registration

    if @term_registration.save
      redirect_to term_student_path(@term, @term_registration), notice: "Student was successfully created."
    else
      render :new
    end
  end

  def edit
    set_term_registration
  end

  def update
    set_term_registration

    if @term_registration.update(edit_term_registration_params)
      redirect_to term_student_path(@term, @term_registration), notice: 'Student was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    set_term_registration

    @term_registration.destroy

    redirect_to term_students_path(@term), notice: 'Student was successfully removed.'
  end

  private

  def set_term_registration
    @term_registration = students_scope.find(params[:id])

    authorize @term_registration
  end

  def set_term_review
    @term_review = GradingReview::TermReview.new(term_registration: @term_registration)
  end

  def new_term_registration_params
    params.require(:term_registration).permit(:student_group_id, :tutorial_group_id, :account_id)
  end

  def edit_term_registration_params
    params.require(:term_registration).permit(:student_group_id, :tutorial_group_id)
  end

  def students_scope
    current_term.term_registrations.students
  end
end
