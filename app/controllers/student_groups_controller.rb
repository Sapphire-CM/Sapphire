class StudentGroupsController < ApplicationController
  include TermContext

  def index
    authorize StudentGroupPolicy.with @term

    @student_groups = current_term.student_groups.multiple
    @student_groups_count = @student_groups.count
    @student_groups = @student_groups.includes(tutorial_group: :tutor_term_registrations)
  end
end
