module SubmissionsHelper
  def submission_title(submission)
    "Submission of #{submission_author(submission)}"
  end

  def submissions_tutorial_group_dropdown(current_tutorial_group)

    button_title = if current_tutorial_group
      tutorial_group_title(current_tutorial_group)
    else
      "All Tutorial groups"
    end

    link = link_to(button_title, '#', data: {dropdown: "tutorial_group_dropdown"}, class: "small button dropdown")

    dropdown = content_tag :ul, id: "tutorial_group_dropdown", class: "f-dropdown" do
      content = ""

      ([nil] + @term.tutorial_groups).each  do |tutorial_group|
        content << content_tag(:li) do
          if tutorial_group.present?
            title = tutorial_group_title(tutorial_group)
            id = tutorial_group.id
          else
            title = "All"
            id = "all"
          end

          link_to(h(title), exercise_submissions_path(tutorial_group_id: id, q: params[:q]))
        end.html_safe
      end

      content.html_safe
    end


    link + dropdown
  end

  def submission_author(submission)
    exercise = submission.exercise
    if submission.student_group.present?
      if exercise.group_submission?
        submission.student_group.title
      else
        student = submission.student_group.students.first
        "#{student.fullname} (#{student.matriculation_number})"
      end
    else
      "unknown author"
    end
  end

  def submission_tutorial_group(submission)
    if submission.student_group.present?
      tutorial_group_title(submission.student_group.tutorial_group)
    else
      "unkown"
    end
  end
end
