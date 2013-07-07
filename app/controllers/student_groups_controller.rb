class StudentGroupsControllerr < TermResourceController
  before_filter :fetch_tutorial_group

  # index action not needed

  def show
    @student_group = tutorial_groups.student_groups.find(params[:id])
  end

  def new
    @student_group = tutorial_groups.student_groups.new
  end

  def create
    @student_group = tutorial_groups.student_groups.new(params[:student_group])

    if @student_group.save
      redirect_to course_term_tutorial_group_path(current_course, current_term, tutorial_group), notice: "Student group successfully created."
    else
      render :new
    end
  end

  def edit
    @student_group = tutorial_groups.student_groups.find(params[:id])
  end

  def update
    @student_group = tutorial_groups.student_groups.find(params[:id])

    if @student_group.update_attributes(params[:student_group])
      redirect_to course_term_tutorial_group_path(current_course, current_term, tutorial_group), notice: "Student group successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @student_group = tutorial_groups.student_groups.find(params[:id])
    @student_group.destroy
    redirect_to course_term_tutorial_group_path(current_course, current_term, tutorial_group), notice: "Student group successfully deleted."
  end

  private
  def fetch_tutorial_group
    @tutorial_group = current_term.tutorial_groups.find(params[:tutorial_group_id])
  end

end
