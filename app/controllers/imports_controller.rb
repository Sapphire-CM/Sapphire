class ImportsController < ApplicationController
  before_action :set_import, only: [:show, :edit, :update, :destroy, :full_mapping_table, :results]

  def show
    @import = Import.find(params[:id])
  end

  def new
    @term = Term.find(params[:term_id])

    @import = Import.new
    @import.term = @term
    @import.build_import_options

    @import.import_options.matching_groups = :both_matches if @term.group_submissions?

    authorize @import
  end

  def create
    @import = Import.new(import_params)
    authorize @import

    @term = @import.term

    return render :new unless @import.save
    @import.reload

    import_service = ImportService.new(@import)

    if import_service.encoding_error?
      render :new, alert: 'Error with file encoding! UTF8-like is required.'
    elsif import_service.parsing_error?
      render :new, alert: 'Error during parsing! Corrupt data detected.'
    else
      # everything worked
      import_service.smart_guess_new_import_mapping
      redirect_to term_import_path(@term, @import)
    end
  end

  def update
    if @import.update(import_params)
      @import.pending!
      ImportJob.perform_later @import.id
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
      import_mapping_attributes: ImportMapping::IMPORTABLE
    )
  end
end
