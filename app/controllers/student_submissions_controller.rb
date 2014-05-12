class StudentSubmissionsController < ApplicationController
  # enable streaming
  include ActionController::Streaming
  # enable zipline
  include Zipline

  SubmissionPolicyRecord = Struct.new :exercise, :tutorial_group do
    def policy_class
      SubmissionPolicy
    end
  end

  before_action :set_exercise_and_term
  before_action :set_submission, only: [:show, :update]
  before_action :ensure_submission_param, only: [:create, :update]

  skip_after_action :verify_authorized, only: :create, if: lambda { params[:submission].blank? }

  def show
    unless current_account.student_of_term? @term
      redirect_to exercise_submissions_path(@exercise)
      return
    end

    @submission = Submission.for_exercise(@exercise).for_account(current_account).first_or_initialize

    @submissions = @exercise.submissions.includes({student_group: [:students, :tutorial_group]}, :submission_evaluation, :exercise).order(:submitted_at)
    @submissions = @submissions.joins(student_group_registration: :student_group).order("student_groups.title ASC")
    @submissions = @submissions.for_tutorial_group @tutorial_group if @tutorial_group.present?
    @submission_count = @submissions.count


    respond_to do |format|
      format.html do
        @submissions = @submissions.page(params[:page]).per(20)
      end
      format.zip do
        files = zip_files(@submissions)
        puts files.to_s
        zipline files, @exercise.title.parameterize.gsub(/-+/, "-")
      end
    end
  end

  def show
    @term = @submission.exercise.term
    @submission_assets = @submission.submission_assets
  end

  def create
    @submission = Submission.new(submission_params)
    @submission.exercise = @exercise
    @submission.submitted_at = Time.now
    @submission.assign_to_account(current_account)

    authorize @submission

    @submission.submitter = current_account

    if @submission.save
      if policy(@term).student?
        redirect_to exercise_student_submission_path(@exercise), notice: "Successfully uploaded submission"
      end
    else
      render :show
    end
  end

  def update
    @submission.assign_attributes(submission_params)
    @submission.submitter = current_account
    @submission.submitted_at = Time.now

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
    @submission = Submission.select(Submission.quoted_table_name + '.*').for_exercise(@exercise).for_account(current_account).first_or_initialize

    authorize @submission
  end

  def zip_files(submissions)
    files = []

    submissions.includes(:submission_assets).map do |submission|
      group_name = submission.student_group.title.parameterize

      submission.submission_assets.map do |submission_asset|
        files << [File.open(submission_asset.file.to_s), File.join(group_name, File.basename(submission_asset.file.to_s))]
      end
    end

    files
  end
end
