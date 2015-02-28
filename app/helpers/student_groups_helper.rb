module StudentGroupsHelper
  def student_group_form_cancel_path(student_group)
    if student_group.persisted?
      term_tutorial_group_student_group_path(current_term, current_tutorial_group, student_group)
    else
      term_tutorial_group_student_groups_path
    end
  end
end
