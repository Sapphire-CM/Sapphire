module TutorialGroupsHelper
  def tutorial_group_title(tutorial_group)
    "#{tutorial_group.title} - #{tutor_name tutorial_group.tutor}"
  end

  def set_tutor_label
    if @tutorial_group.tutor.blank?
      "Set tutor"
    else
      "Change tutor"
    end
  end
end
