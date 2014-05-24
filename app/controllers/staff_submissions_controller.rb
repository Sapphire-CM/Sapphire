class StaffSubmissionsController < ApplicationController
  # enable streaming
  include ActionController::Streaming
  # enable zipline
  include Zipline

  before_action :set_exercise_and_term
  before_action :set_tutorial_group
  before_action :set_submission, only: [:show, :update]
  before_action :set_student_groups, only: [:new, :create, :edit, :update]

  SubmissionPolicyRecord = Struct.new :exercise, :tutorial_group do
    def policy_class
      SubmissionPolicy
    end
  end


  def index
    @submissions = @exercise.submissions
    authorize SubmissionPolicyRecord.new @exercise, @tutorial_group

    @submissions = @submissions.for_tutorial_group(@tutorial_group) if @tutorial_group.present?

    @submission_count = @submissions.count
    @submissions = @submissions.includes({student_group: [:students, :tutorial_group]}, :submission_evaluation, :exercise)
    @submissions = @submissions.ordered_by_student_group

    respond_to do |format|
      format.html do
        @submissions = @submissions.page(params[:page]).per(20)
      end
      format.zip do
        file_path = @exercise.title.parameterize.gsub(/-+/, "-")

        zipline zip_files(@submissions, file_path), file_path
      end
    end
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
      if params[:tutorial_group_id] == "all"
        nil
      else
        @term.tutorial_groups.find(params[:tutorial_group_id])
      end
    else
      current_account.tutorial_groups.where(term: @term).first.presence || @term.tutorial_groups.first
    end
  end

  def zip_files(submissions, prefix = "")
    files = []
    submissions.each do |submission|
      group_name = submission.student_group.title.parameterize

      submission.submission_assets.each do |submission_asset|
        if File.exists? submission_asset.file.to_s
          files << [File.new(submission_asset.file.to_s), File.join(prefix, group_name, File.basename(submission_asset.file.to_s))]
        end
      end
    end
    files
  end
end
