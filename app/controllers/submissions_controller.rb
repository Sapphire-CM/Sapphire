class SubmissionsController < ApplicationController
  SubmissionPolicyRecord = Struct.new :exercise, :tutorial_group do
    def policy_class
      SubmissionPolicy
    end
  end

  before_action :set_exercise_and_term
  before_action :set_submission, only: [:show, :update]
  before_action :ensure_submission_param, only: [:create, :update]

  skip_after_action :verify_authorized, only: :create, if: lambda { params[:submission].blank? }


  def index
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

    authorize SubmissionPolicyRecord.new @exercise, @tutorial_group

    @submissions = @exercise.submissions.includes({student_group: [:students, :tutorial_group]}, :submission_evaluation, :exercise).order(:submitted_at)
    @submissions = @submissions.for_tutorial_group @tutorial_group if @tutorial_group.present?
    @submission_count = @submissions.count
    @submissions = @submissions.page(params[:page]).per(20)
  end

  def show
    if params[:id] == :student
      @submission = Submission.for_exercise(@exercise).for_account(current_account).first_or_initialize
      @submission.student_group = StudentGroup.for_student(current_account).for_term(@term).first
    else
      @submission = @exercise.submissions.find(params[:id])
    end

    @term = @submission.exercise.term
    @submission_assets = @submission.submission_assets
  end

  def create
    @submission = Submission.new(submission_params)
    @submission.exercise = @exercise
    @submission.submitted_at = Time.now
    authorize @submission

    @submission.assign_to_account(current_account)
    @submission.submitter = current_account
    if @submission.save
      if policy(@term).student?
        redirect_to exercise_student_submission_path(@exercise), notice: "Successfully uploaded submission"
      end
    else
      puts @submission.errors.full_messages
      render :show
    end
  end

  def update
    @submission.assign_attributes(submission_params)
    @submission.submitter = current_account
    if @submission.save
      if policy(@term).student?
        redirect_to exercise_student_submission_path(@exercise), notice: "Successfully updated submission"
      end
    else
      render :show
    end
  end

  private
  def submission_params
    params.require(:submission).permit(submission_assets_attributes: [:id, :file])
  end

  def ensure_submission_param
    redirect_to exercise_student_submission_path(@exercise), notice: "Please choose a file to upload" unless params[:submission].present?
  end

  def set_exercise_and_term
    @exercise = Exercise.find params[:exercise_id]
    @term = @exercise.term
  end

  def set_submission
    if params[:id] == :student
      @submission = Submission.for_exercise(@exercise).for_account(current_account).first_or_initialize
      @submission.student_group = StudentGroup.for_student(current_account).for_term(@term).first
    else
      @submission = @exercise.submissions.find(params[:id])
    end
    authorize @submission
  end
end
