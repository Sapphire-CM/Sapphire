class TermsController < ApplicationController
  include TermContext
  before_action :set_term, only: [:show, :edit, :update, :destroy,
                                  :points_overview]

  def show
    @tutorial_groups = @term.tutorial_groups.ordered_by_title
    @exercises = @term.exercises
  end

  def new
    @course = Course.find(params[:course_id])

    @term = TermNew.new
    @term.course = @course

    authorize @term
  end

  def create
    @term = TermNew.new(term_params)
    authorize @term

    if @term.save
      if @term.needs_copying?
        @term.preparing!
        options = {
          lecturers: @term.copy_lecturer?,
          exercises: @term.copy_exercises?,
          grading_scale: @term.copy_grading_scale?
        }
        TermCopyJob.perform_later @term.id, @term.source_term_id, options

        flash[:notice] = 'Term has been successfully created, the previous term is being copied in the background'
      else
        flash[:notice] = 'Term has been successfully created'
      end

      respond_to do |format|
        format.html { redirect_to term_path(@term) }
        format.js
      end
    else
      render :new
    end
  end

  def edit
    @tutorial_groups = @term.tutorial_groups.ordered_by_title
    @exercises = @term.exercises

    @term_registrations_awaiting_welcome = @term.term_registrations.student.waiting_for_welcome
  end

  def update
    if @term.update(term_params)
      respond_to do |format|
        format.html { redirect_to term_path(@term), notice: 'Term has been successfully updated' }
        format.js
      end
    else
      @term_registrations_awaiting_welcome = @term.term_registrations.student.waiting_for_welcome

      render :edit
    end
  end

  def destroy
    @term.destroy
    redirect_to root_path, notice: "Term has been successfully deleted"
  end

  def points_overview
    @grading_scale_service = GradingScaleService.new(@term)
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
      :copy_lecturer
    )
  end
end
