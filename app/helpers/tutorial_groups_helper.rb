module TutorialGroupsHelper
  def tutorial_group_title(tutorial_group)
    if tutorial_group
      "#{tutorial_group.title} - #{tutor_names tutorial_group.tutor_accounts}"
    else
      'none'
    end
  end

  def tutorial_group_select_params(tutorial_groups)
    tutorial_groups.map do |tutorial_group|
      [tutorial_group_title(tutorial_group), tutorial_group.id]
    end
  end

  def set_tutor_label
    if @tutorial_group.tutor.blank?
      'Set tutor'
    else
      'Change tutor'
    end
  end
end
