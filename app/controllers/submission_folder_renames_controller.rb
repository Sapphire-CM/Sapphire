class SubmissionFolderRenamesController < ApplicationController
  include EventSourcing

  before_action :set_submission
  before_action :set_context

  def new
    @submission_folder_rename = SubmissionFolderRename.new(
      renamed_at: Time.now.strftime("%Y-%m-%d %H:%M"),
      path_old:  params[:format],
      renamed_by: current_account
    )
    @submission_folder_rename.submission = @submission
    @submission_folder_rename.directory = @directory
    authorize @submission_folder_rename
  end

  def create
    @submission_folder_rename = SubmissionFolderRename.new({
                                            renamed_at: Time.now.strftime("%Y-%m-%d %H:%M"),
                                            path_old:  params[:format],
                                            renamed_by: current_account
                                          }.merge(submission_folder_rename_params))

    @submission_folder_rename.submission = @submission
    @submission_folder_rename.directory = @directory
    authorize @submission_folder_rename


    if @submission_folder_rename.save!
      event_service.submission_folder_renamed!(@submission_folder_rename)

      redirect_to tree_submission_path(@submission, @directory.parent.try(:path_without_root)),
                  notice:
                    "Successfully renamed directory '#{@submission_folder_rename.path_old}' to '
                      #{@submission_folder_rename.path_new.sub(File.basename(@submission_folder_rename.path_new),
                       @submission_folder_rename.path_new)}'."
    else
      redirect_to tree_submission_path(@submission, @directory.parent.try(:path_without_root)),
                  alert: "Renaming '#{@submission_folder_rename.path_new}' was not successful. Chosen name already in use."
    end
  end

  private

  def set_submission
    @submission = Submission.find(params[:submission_id])
  end

  def set_context
    @exercise = @submission.exercise
    @term = @exercise.term
    @tree = @submission.tree
    @directory = @tree.resolve(params[:format])
  rescue SubmissionStructure::FileNotFound
    raise ActiveRecord::RecordNotFound
  end

  def submission_folder_rename_params
    params.require(:submission_folder_rename).permit(:path_new)
  end

end
