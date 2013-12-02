class SubmissionsController < ApplicationController
  def index
    @exercise = Exercise.find params[:exercise_id]
    @term = @exercise.term

    @submissions = @exercise.submissions.includes({student_group: [:students, :tutorial_group]}, :submission_evaluation, :exercise).order(:submitted_at)


    @tutorial_group = if params[:tutorial_group_id].present?
      if params[:tutorial_group_id] == "all"
        nil
      else
        @term.tutorial_groups.find(params[:tutorial_group_id])
      end
    else
      if tut_group = current_account.tutorial_groups.where(term: @term).first
        tut_group
      else
        @term.tutorial_groups.first
      end
    end

    @submissions = @submissions.for_tutorial_group @tutorial_group if @tutorial_group.present?

    @submissions = @submissions.page(params[:page]).per(20)
  end

  def show
    @submission = Submission.find(params[:id])
    @term = @submission.exercise.term
  end
end
