class StudentGroupsController < ApplicationController
  include TermContext

  before_action :set_student_group, only: [:edit, :update]
  before_action :set_tutorial_groups, only: [:edit, :update]

  def index
    authorize StudentGroupPolicy.with current_term

    @student_groups = current_term.student_groups
    @student_groups_count = @student_groups.count
    @student_groups = @student_groups.includes(tutorial_group: :tutor_term_registrations)
  end

  def edit
  end

  def search_students
    authorize StudentGroupPolicy.with current_term
    @term_registrations = current_term.term_registrations.students.search(params[:q]).includes(:account, :tutorial_group, :student_group).page(params[:p]).per(10)
  end

  private
  def set_student_group
    @student_group = current_term.student_groups.find(params[:id])
    authorize(@student_group)
  end
  def set_tutorial_groups
    @tutorial_groups = current_term.tutorial_groups
  end
end
