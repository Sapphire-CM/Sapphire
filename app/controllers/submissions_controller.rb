class SubmissionsController < ApplicationController
  def show
    @submission = Submission.find(params[:id])
    @term = @submission.exercise.term
  end
end
