class Import::StudentImportsController < TermResourceController
  def index
    @student_imports = Import::StudentImport.with_terms.for_course(@course).decorate
  end
  
  def show
    @student_import = Import::StudentImport.for_course(current_course).find(params[:id]).decorate
  end
  
  def new
    @student_import = @term.student_imports.new
    @student_import.import_options[:col_seperator] = ";"
    @student_import.import_options[:quote_char] = "\""
    @student_import.import_options[:headers_on_first_line] = "1"

    @terms = current_course.terms
  end
  
  def create
    @student_import = @term.student_imports.new(params[:import_student_import])
    
    if @student_import.save
      redirect_to course_term_import_student_import_path(@course, @term, @student_import), :notice => "Import created - wanna start it?"
    else
      render :new
    end
  end
  
  def edit
    @student_import = Import::StudentImport.find(params[:id])
    @terms = current_course.terms
  end
  
  def update
    @student_import = Import::StudentImport.find(params[:id])
    
    @term = @student_import.term
    @terms = current_course.terms
      
    if @student_import.update_attributes(params[:import_student_import])
      redirect_to course_term_import_student_import_path(@course, @term, @student_import), :notice => "Your changes have been saved"
    else
      render :edit
    end
  end
  
  def import
    @student_import = Import::StudentImport.find(params[:id])
    @student_import.import!
    
    redirect_to course_term_import_student_import_path(@course, @term, @student_import), :notice => "Import finished!"
  end
  
  def destroy
    @student_import = Import::StudentImport.find(params[:id])
    
    @student_import.destroy
    redirect_to course_term_import_student_import_path(@course, @term)
  end
end
