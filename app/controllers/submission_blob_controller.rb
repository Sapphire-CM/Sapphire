class SubmissionBlobController < ApplicationController
  include ActionController::Streaming

  before_action :set_submission, only: :show

  rescue_from SubmissionStructure::FileNotFound, with: :redirect_to_submission_tree

  def show
    @tree = @submission.tree
    @directory = @tree.resolve(params[:path])

    respond_to do |format|
      format.zip do
        name = zip_name(@submission, @directory)
        stream_zip(@directory, name, "#{name}.zip")
      end
    end
  end

  private
  def redirect_to_submission_tree
    redirect_to submission_tree_path(@submission, params[:path])
  end

  def set_submission
    @submission = Submission.find(params[:id])

    authorize @submission
  end

  def stream_zip(tree, path, filename)
    data = Zip::OutputStream.write_buffer do |zip|
      add_files_to_zip(tree, path, zip)
    end
    data.rewind

    send_data(data.read, filename: path, content_type: "application/zip")
  end

  def add_files_to_zip(tree, path, output)
    tree.entries.each do |entry|
      sub_path = File.join(path, entry.name)
      if entry.is_a? SubmissionStructure::Directory
        add_files_to_zip(entry, sub_path, output)
      else
        output.put_next_entry sub_path
        output.print entry.submission_asset.file.read
      end
    end
  end

  def zip_name(submission, tree)
    parts = []
    parts << submission.exercise.title.parameterize
    parts << tree.name.parameterize unless tree.root?
    parts.join("_")
  end
end
