class TermsController < ApplicationController
  include TermContext
  before_action :set_term, only: [:show, :edit, :update, :destroy,
                                  :points_overview, :send_welcome_notifications]

  def show
    @tutorial_groups = @term.tutorial_groups
    @exercises = @term.exercises
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
    @tutorial_groups = @term.tutorial_groups
    @exercises = @term.exercises
  end

  def update
    if @term.update(term_params)
      respond_to do |format|
        format.html { redirect_to term_path(@term), notice: 'Term has been successfully updated' }
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

  def points_overview
    @grading_scale_service = GradingScaleService.new(@term)
  end

  def send_welcome_notifications
    NotificationJob.welcome_notifications_for_term(@term)
    redirect_to term_path(@term), notice: 'Welcome Notifications successfully queued for sending'
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
