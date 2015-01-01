class Import::StudentImportsController < ApplicationController
  before_action :set_student_import, only: [:show, :edit, :update, :destroy, :full_mapping_table, :results]

  def show
    @student_import = Import::StudentImport.find(params[:id]).decorate
  end

  def new
    @term = Term.find(params[:term_id])

    @student_imports = @term.student_imports.decorate

    @student_import = Import::StudentImport.new
    @student_import.term = @term
    @student_import.import_options[:matching_groups] = "both" if @term.group_submissions?

    authorize @student_import
  end

  def create
    @student_import = Import::StudentImport.new(student_import_params)
    authorize @student_import

    if not @student_import.save
      @term = @student_import.term
      return render :new
    end

    # TODO: add validation for import_options

    @student_import.parse_csv

    @term = @student_import.term
    if @student_import.encoding_error?
      render :new, alert: "Error with file encoding! UTF8-like is required."
    elsif @student_import.parsing_error?
      render :new, alert: "Error during parsing! Corrupt data detected."
    else
      # everything worked
      @student_import.smart_guess_new_import_mapping
      redirect_to import_student_import_path(@student_import)
    end

  end

  def update
    @student_import.status = :running
    @student_import.import_result = {
      running: true,
      total_rows: 0,
      processed_rows: 0,
      imported_students: 0,
      imported_tutorial_groups: 0,
      imported_term_registrations: 0,
      imported_student_groups: 0,
      imported_student_registrations: 0,
      problems: []
    }

    if @student_import.save && @student_import.update(student_import_params)
      ImportWorker.perform_async(@student_import.id)
      redirect_to results_import_student_import_path(@student_import)
    end
  end

  def full_mapping_table
    @entries = @student_import.values
    @column_count = @student_import.column_count
  end

  def results
  end

  def destroy
    @student_import.destroy
    redirect_to term_import_student_import_path(@term)
  end

  private
    def set_student_import
      @student_import = Import::StudentImport.find(params[:id])
      @term = @student_import.term
      authorize @student_import
    end

    def student_import_params
      params.require(:import_student_import).permit(
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
