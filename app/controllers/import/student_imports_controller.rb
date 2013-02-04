class Import::StudentImportsController < CourseBaseController
  def index
    @course = current_course
    @student_imports = Import::StudentImport.with_terms.for_course(@course).decorate
  end
  
  def show
    @student_import = Import::StudentImport.for_course(current_course).find(params[:id]).decorate
  end
  
  def new
    @student_import = Import::StudentImport.new
    @student_import.term = current_term
    
    @terms = current_course.terms
  end
  
  def create
    @student_import = Import::StudentImport.new(params[:import_student_import])
    @term = @student_import.term
    
    @terms = current_course.terms
    
    if @student_import.save
      redirect_to import_student_import_path(@student_import), :notice => "Import created - wanna start it?"
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
      redirect_to import_student_import_path(@student_import), :notice => "Your changes have been saved"
    else
      render :edit
    end
  end
  
  def import
    @student_import = Import::StudentImport.find(params[:id])
    @student_import.import!
    
    redirect_to import_student_import_path(@student_import), :notice => "Import finished!"
  end
  
  def destroy
    @student_import = Import::StudentImport.find(params[:id])
    
    @student_import.destroy
    redirect_to import_student_imports_path
  end
end
