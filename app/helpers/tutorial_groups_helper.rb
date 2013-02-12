module TutorialGroupsHelper
  def tutorial_group_title(tutorial_group)
    "#{tutorial_group.title} - #{tutor_name tutorial_group.tutor}"
  end
end
