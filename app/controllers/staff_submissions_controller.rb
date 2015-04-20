class StaffSubmissionsController < ApplicationController
  include ScopingHelpers

  before_action :set_context
  before_action :set_submission, only: [:show, :edit, :update, :destroy]
  before_action :set_student_groups, only: [:new, :create, :edit, :update]

  SubmissionPolicyRecord = Struct.new :exercise, :tutorial_group do
    def policy_class
      SubmissionPolicy
    end
  end

  def index
    authorize SubmissionPolicyRecord.new @exercise, @tutorial_group

    @submissions = scoped_submissions(@tutorial_group, @exercise.submissions)
    @submissions = @submissions.uniq.includes({ exercise_registrations: { term_registration: :account } }, :submission_evaluation, :exercise).load
    @submission_count = @submissions.count
  end

  def new
    @submission = @exercise.submissions.new
    authorize @submission

    @submission.submission_assets.build
  end

  def show
  end

  def create
    @submission = @exercise.submissions.new(submission_params)
    authorize @submission

    @submission.submitter = current_account
    @submission.submitted_at = Time.now

    if @submission.save
      redirect_to [@exercise, @submission], notice: 'Submission successfully created'
    else
      @submission.submission_assets.build
      render :new
    end
  end

  def edit
  end

  def update
    if @submission.update(submission_params)
      redirect_to exercise_submission_path(@exercise, @submission), notice: 'Submission successfully updated'
    else
      render :edit
    end
  end

  def destroy
    @submission.destroy
    redirect_to exercise_submissions_path(@exercise)
  end

  private

  def submission_params
    params.require(:submission).permit(
      :submitted_at,
      :student_group_id,
      submission_assets_attributes: [
        :id,
        :file,
        :_destroy
      ])
  end

  def set_context
    @exercise = Exercise.find params[:exercise_id]
    @term = @exercise.term
    @tutorial_group = current_tutorial_group(@term)
  end

  def set_submission
    @submission = @exercise.submissions.find(params[:id])
    authorize @submission
  end

  def set_student_groups
    @student_groups = @term.student_groups.order(:title)

    @student_groups = @student_groups.for_tutorial_group(@tutorial_group) if @tutorial_group.present?

    @student_groups
  end
end
