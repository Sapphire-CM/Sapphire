class StaffSubmissionsController < ApplicationController
  include ScopingHelpers

  before_action :set_context

  def index
    authorize SubmissionPolicy.term_policy_record(@term)

    @submissions = scoped_submissions(@tutorial_group, @exercise.submissions)
    @submissions = @submissions.uniq.includes({ exercise_registrations: { term_registration: :account } }, :submission_evaluation, :exercise).load
    @submission_count = @submissions.count
  end

  private

  def set_context
    @exercise = Exercise.find params[:exercise_id]
    @term = @exercise.term
    @tutorial_group = current_tutorial_group(@term)
  end
end
