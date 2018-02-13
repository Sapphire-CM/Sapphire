class Submissions::StudentsController < ApplicationController
  def index
    set_submission
    set_context

    @term_registrations = @term.term_registrations.students.search(params[:q])
  end

  private
  def set_submission
    @submission = Submission.find(params[:submission_id])

    authorize @submission, :edit?
  end

  def set_context
    @exercise = @submission.exercise
    @term = @exercise.term
  end
end
