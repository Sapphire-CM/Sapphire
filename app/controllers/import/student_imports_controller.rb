class Import::StudentImportsController < TermResourceController
  def index
    @student_imports = Import::StudentImport.with_terms.for_course(current_course).decorate
  end
  
  def show
    @student_import = Import::StudentImport.for_course(current_course).find(params[:id]).decorate
  end
  
  def new
    @student_import = current_term.student_imports.new

    # default values
    @student_import.import_options[:col_seperator] = ";"
    @student_import.import_options[:quote_char] = "\""
    @student_import.import_options[:headers_on_first_line] = "1"
  end
  
  def create
    @student_import = current_term.student_imports.new(params[:import_student_import])
    
    if @student_import.save
      redirect_to course_term_import_student_import_path(current_course, current_term, @student_import)
    else
      render :new, :notice => "Error during saving!"
    end
  end
  
  def update
    @student_import = Import::StudentImport.find(params[:id])
          
    if @student_import.update_attributes(params[:import_student_import]) && @student_import.import!
      redirect_to course_term_term_registrations_path(current_course, current_term), :notice => "Import successfully finished!"
    else
      @student_import = Import::StudentImport.for_course(current_course).find(params[:id]).decorate
      render :show, :notice => "Error during importing studentes!"
    end
  end
  
  def destroy
    @student_import = Import::StudentImport.find(params[:id])
    @student_import.destroy
    
    redirect_to course_term_import_student_import_path(current_course, current_term)
  end
end
