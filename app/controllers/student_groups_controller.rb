class StudentGroupsControllerr < ApplicationController
  before_action :set_context
  before_action :set_student_group, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    @student_group = tutorial_groups.student_groups.new
  end

  def create
    @student_group = tutorial_groups.student_groups.new(student_group_params)

    if @student_group.save
      redirect_to tutorial_group_path(tutorial_group), notice: "Student group successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @student_group.update_attributes(student_group_params)
      redirect_to tutorial_group_path(tutorial_group), notice: "Student group successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @student_group.destroy
    redirect_to tutorial_group_path(tutorial_group), notice: "Student group successfully deleted."
  end

  private
    def set_context
      @tutorial_group = TutorialGroup.find(params[:tutorial_group_id])
      @term = @tutorial_group.term
    end

    def set_student_group
      @student_group = StudentGroup.find(params[:id])
    end

    def student_group_params
      params.require(:student_group).permit(
        :tutorial_group_id
        :title,
        :solitary)
    end
end
