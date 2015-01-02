class ImportsController < ApplicationController
  before_action :set_import, only: [:show, :edit, :update, :destroy, :full_mapping_table, :results]

  def show
    @import = Import.find(params[:id]).decorate
  end

  def new
    @term = Term.find(params[:term_id])

    @import = Import.new
    @import.term = @term
    @import.build_import_options

    @import.import_options.matching_groups = :both if @term.group_submissions?

    authorize @import
  end

  def create
    @import = Import.new(import_params)
    authorize @import

    @term = @import.term

    unless @import.save
      return render :new
    end

    import_service = ImportService.new(@import)

    if import_service.encoding_error?
      render :new, alert: "Error with file encoding! UTF8-like is required."
    elsif import_service.parsing_error?
      render :new, alert: "Error during parsing! Corrupt data detected."
    else
      # everything worked
      import_service.smart_guess_new_import_mapping
      redirect_to term_import_path(@term, @import)
    end
  end

  def update
    if @import.update(import_params)
      @import.pending!
      ImportWorker.perform_async(@import.id)
      redirect_to results_term_import_path(@term, @import)
    else
      render :show
    end
  end

  def full_mapping_table
    import_service = ImportService.new(@import)
    @entries = import_service.values
    @column_count = import_service.column_count
  end

  def results
    if @import.finished?
      return js_redirect_to term_import_path(@term, @import)
    end
  end

  def destroy
    @import.destroy
    redirect_to new_term_import_path(@term)
  end

  private
    def set_import
      @import = Import.find(params[:id])
      @term = @import.term
      authorize @import
    end

    def import_params
      params.require(:import).permit(
        :term_id,
        :file,
        :file_cache,
        :format,
        :status,
        :line_count,
        :import_mapping,
        import_options_attributes: [
          :matching_groups,
          :tutorial_groups_regexp,
          :student_groups_regexp,
          :headers_on_first_line,
          :column_separator,
          :quote_char,
          :decimal_separator,
          :thousands_separator,
        ],
        import_mappings_attributes: [
          :group,
          :email,
          :forename,
          :surname,
          :matriculation_number,
          :comment,
        ]
      )
    end
end
