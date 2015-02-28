class StudentGroupsController < ApplicationController
  include TutorialGroupContext

  before_action :set_student_group, only: [:show, :edit, :update, :destroy]

  def index
    authorize StudentGroupPolicy.with current_term

    @student_groups = current_tutorial_group.student_groups.order(:title)
    @student_groups_count = @student_groups.count
    @student_groups = @student_groups.includes(tutorial_group: :tutor_term_registrations)
  end

  def show
    @student_term_registrations = @student_group.term_registrations
    @submissions = @student_group.submissions.joins(:exercise).includes(:exercise).order { exercise.row_order}
  end

  def new
    @student_group = current_tutorial_group.student_groups.new
    authorize @student_group
  end

  def create
    @student_group = StudentGroup.new(student_group_params)
    @student_group.tutorial_group = current_tutorial_group
    authorize @student_group

    if @student_group.term == current_term && @student_group.save
      redirect_to term_tutorial_group_student_group_path(current_term, current_tutorial_group, @student_group), notice: "Successfully created student group"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @student_group.update(student_group_params)
      redirect_to term_tutorial_group_student_group_path(current_term, current_tutorial_group, @student_group), notice: "Successfully updated student group"
    else
      render :new
    end
  end

  def destroy
    @student_group.destroy
    redirect_to term_tutorial_group_student_groups_path(current_term, current_tutorial_group), notice: "Successfully removed #{@student_group.title}"
  end

  def search_students
    authorize StudentGroupPolicy.with current_term
    @term_registrations = current_term.term_registrations.students.search(params[:q]).includes(:account, :tutorial_group, :student_group).page(params[:p]).per(10)
  end

  private
  def student_group_params
    params.require(:student_group).permit(:title, term_registration_ids: [])
  end

  def set_student_group
    @student_group = current_term.student_groups.find(params[:id])
    authorize(@student_group)
  end
end
