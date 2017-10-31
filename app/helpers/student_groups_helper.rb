module StudentGroupsHelper
  def student_group_form_cancel_path(term, student_group)
    if student_group.persisted?
      term_student_group_path(term, student_group)
    else
      term_student_groups_path(term)
    end
  end
end
