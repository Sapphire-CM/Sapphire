class StudentGroupsController < ApplicationController
  include TermContext

  before_action :set_student_group, only: [:show, :edit, :update, :destroy]

  def index
    authorize StudentGroupPolicy.term_policy_record(current_term)

    @student_groups = current_term.student_groups.order(:title)
    @student_groups = @student_groups.includes(:students, tutorial_group: :tutor_accounts)
  end

  def show
    @student_term_registrations = @student_group.term_registrations.includes(:account)
    @submissions = @student_group.submissions.ordered_by_exercises.includes(:exercise, :submission_evaluation)
  end

  def new
    @student_group = StudentGroup.new

    authorize StudentGroupPolicy.term_policy_record(current_term)
  end

  def create
    @student_group = StudentGroup.new(student_group_params)

    authorize StudentGroupPolicy.term_policy_record(current_term)

    if @student_group.save
      redirect_to term_student_group_path(current_term, @student_group), notice: 'Successfully created student group'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @student_group.update(student_group_params)
      redirect_to term_student_group_path(current_term, @student_group), notice: 'Successfully updated student group'
    else
      render :edit
    end
  end

  def destroy
    @student_group.destroy
    redirect_to term_student_groups_path(current_term), notice: "Successfully removed #{@student_group.title}"
  end

  def search_students
    authorize StudentGroupPolicy.term_policy_record(current_term)

    if params[:q].blank?
      head :bad_request
      return
    end

    @term_registrations = current_term.term_registrations.students.includes(:account, :tutorial_group, :student_group).search(params[:q]).page(params[:p]).per(10)

    respond_to do |format|
      format.js
    end
  end

  private

  def student_group_params
    params.require(:student_group).permit(:title, :keyword, :topic, :description, :tutorial_group_id, term_registration_ids: [])
  end

  def set_student_group
    @student_group = current_term.student_groups.find(params[:id])

    authorize(@student_group)
  end
end
