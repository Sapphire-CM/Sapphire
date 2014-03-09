class TermsController < ApplicationController
  before_action :set_term, only: [:show, :edit, :update, :destroy,
    :new_lecturer_registration, :create_lecturer_registration, :clear_lecturer_registration,
    :grading_scale, :update_grading_scale, :points_overview]

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
      if not @term.copy_elements.to_i.zero?
        source_term = Term.find(@term.source_term_id)

        source_term.copy_lecturer(@term) unless @term.copy_lecturer.to_i.zero?
        source_term.copy_exercises(@term) unless @term.copy_exercises.to_i.zero?
        source_term.copy_grading_scale(@term) unless @term.copy_grading_scale.to_i.zero?
      end

      render partial: 'terms/insert_index_entry', locals: { term: @term }
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @term.update(term_params)
      render partial: 'terms/replace_index_entry', locals: { term: @term }
    else
      render :edit
    end
  end

  def destroy
    @term.destroy
    render partial: 'terms/remove_index_entry', locals: { term: @term }
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

  def grading_scale
    render partial: 'points_overview/grade_distribution',
      locals: {
        entry_partial: 'terms/grading_scale_entry',
        students: @term.students,
        grade_distribution: @term.grade_distribution(@term.students) }
  end

  def update_grading_scale
    grade = params[:grading_scale].to_a[0][0]
    low = params[:grading_scale].to_a[0][1]

    pair = @term.grading_scale.select{|l,g| g == grade}.first
    @term.grading_scale.delete pair
    @term.grading_scale << [low.to_i, grade]
    @term.save!
  end

  def points_overview
    @students = @term.students
    @grade_distribution = @term.grade_distribution @students
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
