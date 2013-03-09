class TermsController < TermResourceController
  before_filter :fetch_course_term

  # index action not needed

  def show
    @tutorial_groups = @term.tutorial_groups
    @exercises = @term.exercises

    if @term.lecturer.blank?
      render :alert => 'You have not set a lecturer yet!'
    end
  end

  def new
    @term = @course.terms.new
  end

  def create
    @term = @course.terms.new(params[:term])

    if @term.save
      redirect_to course_term_path(@course, @term), :notice => "Term was successfully created."
    else
      render :new
    end
  end

  def edit
    # term is fetched with before_filter
  end

  def update
    if @term.update_attributes(params[:term])
      redirect_to course_term_path(@course, @term), :notice => "Term was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @term.destroy
    redirect_to course_path(@course), :notice => "Term was successfully deleted."
  end

  def new_lecturer_registration
    @accounts = Account.scoped.page(params[:page]).per(50)
    @accounts = @accounts.search(params[:q]) if params[:q].present?
  end

  def create_lecturer_registration
    @account = Account.find(params[:account_id])

    registration = LecturerRegistration.find_or_initialize_by_term_id(@term.id)
    registration.lecturer = @account
    registration.registered_at = DateTime.now

    if registration.save
      redirect_to course_term_path(current_course, current_term), notice: "Lecturer registration successfully added."
    else
      redirect_to course_term_path(current_course, current_term), alert: "Lecturer registration failed!"
    end
  end

  def clear_lecturer_registration
    @term.lecturer_registration.destroy

    redirect_to course_term_path(current_course, current_term), notice: "Lecturer registration successfully cleared!"
  end

  private

  def fetch_course_term
    @course = current_course
    @term = current_term
  end
end
