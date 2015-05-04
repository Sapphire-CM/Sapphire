require 'zip'
require 'base64'

class StudentSubmissionsController < ApplicationController
  before_action :set_exercise_and_term
  before_action :set_submission, only: [:show, :update, :catalog, :extract]
  before_action :ensure_submission_param, only: [:create, :update]

  skip_after_action :verify_authorized, only: :create, if: lambda { params[:submission].blank? }

  def show
    unless current_account.student_of_term? @term
      redirect_to exercise_submissions_path(@exercise)
      return
    end

    @submission_assets = @submission.submission_assets
  end

  def create
    creation_service = SubmissionCreationService.new_with_params(current_account, @exercise, submission_params)
    authorize creation_service.model

    if creation_service.save
      if policy(@term).student?
        if creation_service.model.submission_assets.archives.any?
          redirect_to catalog_exercise_student_submission_path(@exercise)
        else
          redirect_to exercise_student_submission_path(@exercise), notice: 'Successfully uploaded submission'
        end
      end
    else
      @submission = creation_service.model
      render :show, alert: 'Submission upload failed!'
    end
  end

  def update
    @submission.assign_attributes(submission_params)
    @submission.submitted_at = Time.now

    if @submission.save
      if policy(@term).student?
        if @submission.submission_assets.archives.any?
          redirect_to catalog_exercise_student_submission_path(@exercise)
        else
          redirect_to exercise_student_submission_path(@exercise), notice: 'Successfully updated submission'
        end
      end
    else
      render :show
    end
  end

  def catalog
    @archives = @submission.submission_assets.archives

    if @archives.blank?
      redirect_to exercise_student_submission_path(@exercise), notice: 'Nothing to extract'
    end
  end

  def extract
    if @exercise.enable_max_upload_size && new_total_submission_size > @exercise.maximum_upload_size
      redirect_to catalog_exercise_student_submission_path(@exercise), alert: 'Maximum upload size reached'
      return
    end

    extract_files!

    redirect_to exercise_student_submission_path(@exercise), notice: 'Successfully extracted submission'
  end

  private

  def set_exercise_and_term
    @exercise = Exercise.find params[:exercise_id]
    @term = @exercise.term
  end

  def set_submission
    @submission = Submission.select(Submission.quoted_table_name + '.*').for_account(current_account).for_exercise(@exercise).first_or_initialize

    authorize @submission
  end

  def submission_params
    params.require(:submission).permit(submission_assets_attributes: [:id, :file, :_destroy])
  end

  def ensure_submission_param
    redirect_to exercise_student_submission_path(@exercise), notice: 'Please choose a file to upload' unless params[:submission].present?
  end

  def files_to_extract
    @files_to_extract ||= begin
      list = {}
      params[:submission_assets].each do |id, archive_params|
        files = archive_params.map { |_, ap| { id: ap[:id], full_path: ap[:full_path] } if ap[:extract] == '1' }.compact
        files.reject! { |f| SubmissionAsset::EXCLUDED_FILTER.map { |e| f[:full_path] =~ e }.any? }
        files.map! { |f| Base64.decode64(f[:id]) }

        list[id] = files if files.length > 0
      end if params[:submission_assets]

      list
    end
  end

  def new_total_submission_size
    @new_total_submission_size ||= begin
      archives_to_keep = @submission.submission_assets.where.not(id: files_to_extract.keys)
      size_to_keep = archives_to_keep.map(&:filesize).sum

      new_files_size = files_to_extract.map do |id, files|
        sa = @submission.submission_assets.find(id)
        Zip::File.open(sa.file.to_s) do |zip_file|
          files.sum { |f| zip_file.find_entry(f).size }
        end
      end.sum

      size_to_keep + new_files_size
    end
  end

  def extract_files!
    files_to_extract.each do |id, files|
      sa = @submission.submission_assets.find(id)
      Zip::File.open(sa.file.to_s) do |zip_file|
        files.each do |file|
          entry = zip_file.find_entry file
          next unless entry

          destination = File.join Dir.tmpdir, File.basename(file)
          zip_file.extract entry, destination

          path = File.dirname(file)
          path = '' if path == '.'
          @submission.submission_assets.create! file: File.open(destination), path: path
        end
      end

      sa.destroy
    end
  end
end
