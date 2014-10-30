class StaffSubmissionsController < ApplicationController
  # enable streaming
  include ActionController::Streaming
  # enable zipline
  include Zipline

  before_action :set_exercise_and_term
  before_action :set_tutorial_group
  before_action :set_submissions, only: :index
  before_action :set_submission, only: [:show, :update]
  before_action :set_student_groups, only: [:new, :create, :edit, :update]

  SubmissionPolicyRecord = Struct.new :exercise, :tutorial_group do
    def policy_class
      SubmissionPolicy
    end
  end


  def index
    authorize SubmissionPolicyRecord.new @exercise, @tutorial_group

    @submission_count = @submissions.count
    @submissions = @submissions.includes({exercise_registrations: {term_registration: :account}}, :submission_evaluation, :exercise).load
    @submissions = @submissions.page(params[:page]).per(20)
  end

  def new
    @submission = @exercise.submissions.new
    @submission.submitted_at = Time.now
    authorize @submission
    @submission.submission_assets.build
  end

  def create
    @submission = @exercise.submissions.new(submission_params)
    authorize @submission
    @submission.submitter = current_account

    if @submission.save
      redirect_to [@exercise, @submission], notice: "Submission successfully created"
    else
      render :new
    end
  end

  def edit
    @submission = @exercise.submissions.find(params[:id])
    authorize @submission
  end

  def update
    @submission = @exercise.submissions.find(params[:id])
    authorize @submission

    if @submission.update(submission_params)
      redirect_to exercise_submission_path(@exercise, @submission), notice: "Submission successfully updated"
    else
      render :edit
    end
  end

  def destroy
    @submission = @exercise.submissions.find(params[:id])
    authorize @submission
    @submission.destroy

    redirect_to exercise_submissions_path(@exercise)
  end

  private
  def submission_params
    params.require(:submission).permit(:submitted_at, :student_group_id, submission_assets_attributes: [:id, :file, :_destroy])
  end

  def set_exercise_and_term
    @exercise = Exercise.find params[:exercise_id]
    @term = @exercise.term
  end

  def set_submission
    @submission = @exercise.submissions.find(params[:id])
    authorize @submission
  end

  def set_student_groups
    @student_groups = @term.student_groups.active.order(:title)

    @student_groups = @student_groups.for_tutorial_group(@tutorial_group) if @tutorial_group.present?

    @student_groups = if @exercise.group_submission?
      @student_groups.multiple
    else
      @student_groups.solitary
    end
    @student_groups
  end

  def set_tutorial_group
    @tutorial_group = if params[:tutorial_group_id].present?
      @term.tutorial_groups.find(params[:tutorial_group_id])
    else
      current_account.tutorial_groups.where(term: @term).first.presence || @term.tutorial_groups.first
    end
  end

  def set_submissions
    scoped_submissions = @exercise.submissions.order(submitted_at: :desc)

    @submissions = case params[:submission_scope]
    when "unmatched"
      scoped_submissions.unmatched
    when "all"
      scoped_submissions
    else
      scoped_submissions.for_tutorial_group(@tutorial_group)
    end
  end
end
