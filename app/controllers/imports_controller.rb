class ImportsController < ApplicationController
  before_action :set_import, only: [:show, :edit, :update, :destroy, :full_mapping_table, :results]

  def show
    @import = Import.find(params[:id]).decorate
  end

  def new
    @term = Term.find(params[:term_id])

    @import = Import.new
    @import.term = @term
    @import.import_options[:matching_groups] = "both" if @term.group_submissions?

    authorize @import
  end

  def create
    @import = Import.new(import_params)
    authorize @import

    @term = @import.term

    if not @import.save
      return render :new
    end

    # TODO: add validation for import_options

    @import.parse_csv

    if @import.encoding_error?
      render :new, alert: "Error with file encoding! UTF8-like is required."
    elsif @import.parsing_error?
      render :new, alert: "Error during parsing! Corrupt data detected."
    else
      # everything worked
      @import.smart_guess_new_import_mapping
      redirect_to term_import_path(@term, @import)
    end

  end

  def update
    p = import_params
    p[:status] = :running
    p[:import_result] = {
      total_rows: 0,
      processed_rows: 0,
      imported_students: 0,
      imported_tutorial_groups: 0,
      imported_term_registrations: 0,
      imported_student_groups: 0,
      imported_student_registrations: 0,
      problems: [],
    }

    if @import.save && @import.update(p)
      ImportWorker.perform_async(@import.id)
      redirect_to results_term_import_path(@term, @import)
    end
  end

  def full_mapping_table
    @entries = @import.values
    @column_count = @import.column_count
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
        :import_mapping,
        import_options: [
          :matching_groups, :tutorial_groups_regexp, :student_groups_regexp,
          :headers_on_first_line, :column_separator, :quote_char, :decimal_separator,
          :thousands_separator ]
        )
    end
end
