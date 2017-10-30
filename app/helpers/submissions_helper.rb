module SubmissionsHelper
  def submission_title(submission)
    "Submission of #{submission_author(submission)}"
  end

  def submissions_tutorial_group_dropdown(current_tutorial_group)
    button_title = case params[:submission_scope]
    when 'all'
      'All Tutorial Groups'
    when 'unmatched'
      'Unmatched Submissions'
    else
      tutorial_group_title(current_tutorial_group)
    end

    link = link_to(button_title, '#', data: { dropdown: 'tutorial_group_dropdown' }, class: 'small button dropdown')

    dropdown = content_tag :ul, id: 'tutorial_group_dropdown', class: 'f-dropdown' do
      content = []

      content << content_tag(:li, link_to('All', submission_scope: 'all', q: params[:q]).html_safe)

      @term.tutorial_groups.ordered_by_title.each  do |subject|
        content << content_tag(:li) do
          title = tutorial_group_title(subject)
          id = subject.id

          link_to(h(title), submission_scope: 'tutorial_group', tutorial_group_id: id, q: params[:q])
        end.html_safe
      end

      content << content_tag(:li, link_to('Unmatched', submission_scope: 'unmatched', q: params[:q]).html_safe)

      content.join.html_safe
    end

    link + dropdown
  end

  def submission_author(submission)
    exercise = submission.exercise
    if submission.exercise_registrations.any?
      if exercise.group_submission?
        if submission.student_group_id?
          submission.student_group.title
        else
          content_tag(:em, 'unknown student group')
        end

      else
        student = submission.exercise_registrations.map(&:term_registration).first.account

        account_fullname_with_matriculation_number(student)
      end
    else
      'unknown author'
    end
  end

  def submission_tutorial_group(submission)
    if submission.student_group.present?
      tutorial_group_title(submission.student_group.tutorial_group)
    else
      'unknown'
    end
  end

  def setup_submission(submission)
    submission.submission_assets.build unless submission.submission_assets.any?
    submission
  end

  def submission_subtitle(submission)
    if policy(submission.exercise.term).student?
      'Submission'
    else
      "Submission of #{submission.student_group.title}"
    end
  end

  def filesize(number)
    content_tag :span, raw("#{h(number)}&nbsp;bytes"), title: number_to_human_size(number)
  end
end
