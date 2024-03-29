class ExportsController < ApplicationController
  include TermContext

  before_action :fetch_export, only: [:download, :destroy]

  def index
    @exports = current_term.exports.order(created_at: :desc)
    authorize ExportPolicy.term_policy_record current_term
  end

  def new
    @export_type = params[:type]
    if Export.valid_type?(@export_type)
      @export = Export.new_from_type(@export_type)
      @export.term = current_term
      @export.set_default_values!
      authorize @export
    else
      authorize ExportPolicy.term_policy_record current_term
    end
  end

  def create
    @export_type = params[:type]
    if Export.valid_type?(@export_type) && @export = Export.new_from_type(@export_type, export_params)
      @export.term = current_term

      authorize @export
      if @export.save
        ExportJob.perform_later @export

        redirect_to term_exports_path(current_term), notice: 'Export has been started, you will be notified when it is finished'
      else
        authorize ExportPolicy.term_policy_record(current_term)
        render :new
      end
    else
      authorize ExportPolicy.term_policy_record(current_term)

      redirect_to new_term_export_path(current_term), alert: 'Exporter not found'
    end
  end

  def destroy
    @export.destroy
    redirect_to term_exports_path(current_term), notice: 'Export successfully deleted'
  end

  def download
    if @export.finished? && @export.file.file
      send_file @export.file.to_s
    else
      redirect_to term_exports_path(current_term), alert: 'Export is not ready for download yet'
    end
  end

  private

  def export_params
    params.require(:export).permit Export.class_from_type(@export_type).properties
  end

  def fetch_export
    @export = current_term.exports.find(params[:id])
    authorize @export
  end
end
