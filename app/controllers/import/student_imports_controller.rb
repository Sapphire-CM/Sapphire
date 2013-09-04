class Import::StudentImportsController < ApplicationController
  before_action :set_student_import, only: [:show, :edit, :update, :destroy, :results]

  def index
    @student_imports = Import::StudentImport.all.decorate
  end

  def show
    @student_import = Import::StudentImport.find(params[:id]).decorate
  end

  def full_mapping_table
    @entries = @student_import.values
    @column_count = @student_import.column_count
  end

  def new
    @term = Term.find(params[:term_id])
    @student_import = Import::StudentImport.new
    @student_import.term = @term
    @student_import.import_options[:matching_groups] = "both" if @term.group_submissions?
  end

  def create
    @student_import = Import::StudentImport.new(params[:import_student_import])

    if not @student_import.save
      return render :new
    end

    # TODO: add validation for import_options

    @student_import.parse_csv

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
    result = @student_import.import(params[:import_student_import])
    redirect_to results_import_student_import_path(@student_import)
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
    end
end
