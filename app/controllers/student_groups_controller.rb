class StudentGroupsControllerr < ApplicationController
  before_action :set_context

  def show
    @student_group = tutorial_groups.student_groups.find(params[:id])
  end

  def new
    @student_group = tutorial_groups.student_groups.new
  end

  def create
    @student_group = tutorial_groups.student_groups.new(params[:student_group])

    if @student_group.save
      redirect_to tutorial_group_path(tutorial_group), notice: "Student group successfully created."
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
      redirect_to tutorial_group_path(tutorial_group), notice: "Student group successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @student_group = tutorial_groups.student_groups.find(params[:id])
    @student_group.destroy
    redirect_to tutorial_group_path(tutorial_group), notice: "Student group successfully deleted."
  end

  private
    def set_context
      @tutorial_group = TutorialGroup.find(params[:tutorial_group_id])
      @term = @tutorial_group.term
    end

end
