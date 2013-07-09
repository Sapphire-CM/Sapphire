class Import::StudentImportsController < TermResourceController
  def index
    @student_imports = Import::StudentImport.with_terms.for_course(current_course).decorate
  end

  def show
    @student_import = Import::StudentImport.for_course(current_course).find(params[:id]).decorate
  end

  def full_mapping_table
    @student_import = Import::StudentImport.for_course(current_course).find(params[:id])
    @entries = @student_import.values
    @column_count = @student_import.column_count
  end

  def new
    @student_import = current_term.student_imports.new
    @student_import.import_options[:matching_groups] = "both" if current_term.group_submissions?
  end

  def create
    @student_import = current_term.student_imports.new(params[:import_student_import])

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
      redirect_to course_term_import_student_import_path(current_course, current_term, @student_import)
    end
  end

  def update
    @student_import = Import::StudentImport.find(params[:id])

    result = @student_import.import(params[:import_student_import])

    redirect_to results_course_term_import_student_import_path(current_course, current_term, @student_import)
  end

  def results
    @student_import = Import::StudentImport.find(params[:id])
  end

  def destroy
    @student_import = Import::StudentImport.find(params[:id])
    @student_import.destroy

    redirect_to course_term_import_student_import_path(current_course, current_term)
  end
end
