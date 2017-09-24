class StudentGroupsController < ApplicationController
  include TutorialGroupContext

  include EventSourcing

  before_action :set_student_group, only: [:show, :edit, :update, :destroy]

  def index
    authorize StudentGroupPolicy.with current_tutorial_group

    @student_groups = current_tutorial_group.student_groups.order(:title)
    @student_groups_count = @student_groups.count
    @student_groups = @student_groups.includes(tutorial_group: :tutor_term_registrations)
  end

  def show
    @student_term_registrations = @student_group.term_registrations
    @submissions = @student_group.submissions.joins(:exercise).includes(:exercise).order { exercise.row_order }
  end

  def new
    @student_group = current_tutorial_group.student_groups.new
    authorize @student_group
  end

  def create
    @student_group = StudentGroup.new(student_group_params)
    @student_group.tutorial_group = current_tutorial_group
    authorize @student_group

    if @student_group.save
      redirect_to term_tutorial_group_student_group_path(current_term, current_tutorial_group, @student_group), notice: 'Successfully created student group'
    else
      render :new
    end
  end

  def edit
  end

  def update
    current_ids = @student_group.term_registration_ids
    if @student_group.update(student_group_params)
      added_ids = @student_group.term_registration_ids - current_ids
      removed_ids = current_ids - @student_group.term_registration_ids
      added_term_registrations = TermRegistration.find(added_ids)
      removed_term_registrations = TermRegistration.find(removed_ids)
      puts "ADDED #{added_term_registrations.count}" if added_term_registrations.present?
      puts "REMOVED #{removed_term_registrations.count}" if removed_term_registrations.present?
=begin
    current_ids = @student_group.students #need deep copy...
      if @student_group.update(student_group_params)
      added = @student_group.students - current_ids
      removed = current_ids - @student_group.students 
=end

      event_service.student_group_updated!(@student_group, removed_term_registrations, added_term_registrations)
      redirect_to term_tutorial_group_student_group_path(current_term, current_tutorial_group, @student_group), notice: 'Successfully updated student group'
    else
      render :edit
    end
  end

  def destroy
    @student_group.destroy
    redirect_to term_tutorial_group_student_groups_path(current_term, current_tutorial_group), notice: "Successfully removed #{@student_group.title}"
  end

  def search_students
    authorize StudentGroupPolicy.with current_term

    if params[:q].blank?
      render nothing: true, status: :bad_request
      return
    end

    @term_registrations = current_term.term_registrations.students.includes(:account, :tutorial_group, :student_group).search(params[:q]).page(params[:p]).per(10)

    respond_to do |format|
      format.js
    end
  end

  private

  def student_group_params
    params.require(:student_group).permit(:title, :keyword, :topic, :description, term_registration_ids: [])
  end

  def set_student_group
    @student_group = current_term.student_groups.find(params[:id])
    authorize(@student_group)
  end
end
