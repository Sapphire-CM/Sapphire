class TermsController < ApplicationController
  before_action :set_term, only: [:show, :edit, :update, :destroy,
    :new_lecturer_registration, :create_lecturer_registration, :clear_lecturer_registration,
    :update_grading_scale, :points_overview]

  def show
    @tutorial_groups = @term.tutorial_groups
    @exercises = @term.exercises

    if @term.lecturer.blank?
      render alert: 'You have not set a lecturer yet!'
    end
  end

  def new
    @term = TermNew.new
    @term.course = Course.find(params[:course_id])
    authorize @term
  end

  def create
    @term = TermNew.new(term_params)
    authorize @term

    if @term.save
      CreateTermService.new(@term).perform!

      respond_to do |format|
        format.html { redirect_to term_path(@term), notice: "Term has been successfully created" }
        format.js
      end
    else
      render :new
    end
  end

  def edit
    @tutorial_groups = @term.tutorial_groups
    @exercises = @term.exercises
  end

  def update
    if @term.update(term_params)
      respond_to do |format|
        format.html { redirect_to term_path(@term), notice: "Term has been successfully updated" }
        format.js
      end
    else
      render :edit
    end
  end

  def destroy
    @term.destroy
    redirect_to root_path
  end

  def new_lecturer_registration
    @accounts = Account.scoped.page(params[:page]).per(50)
    @accounts = @accounts.search(params[:q]) if params[:q].present?
  end

  def create_lecturer_registration
    registration = LecturerRegistration.find_or_initialize_by(term_id: @term.id)
    registration.lecturer = Account.find(params[:account_id])

    if registration.save
      redirect_to @term, notice: "Lecturer registration successfully added."
    else
      redirect_to @term, alert: "Lecturer registration failed!"
    end
  end

  def clear_lecturer_registration
    @term.lecturer_registration.destroy
    redirect_to @term, notice: "Lecturer registration successfully cleared!"
  end

  def points_overview
    @grading_scale = GradingScaleService.new(@term)
  end

  private
  def set_term
    @term = Term.find(params[:id] || params[:term_id])
    authorize @term
  end

  def term_params
    params.require(:term).permit(
      :course_id,
      :title,
      :description,
      :source_term_id,
      :copy_elements,
      :copy_exercises,
      :copy_grading_scale,
      :copy_lecturer)
  end
end
