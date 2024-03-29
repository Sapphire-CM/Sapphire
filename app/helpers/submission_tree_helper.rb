module SubmissionTreeHelper
  def submission_tree_path_links(path, submission)
    parts = path.split(File::SEPARATOR).keep_if(&:present?)

    debug parts

    links = [link_to(h(submission.exercise.title), exercise_submission_tree_path(submission.exercise, submission))]
    links += parts.map.with_index do |dir, idx|
      tree = parts[0..idx].join(File::SEPARATOR)
      link_to(h(dir), exercise_submission_tree_path(submission.exercise, submission, tree))
    end

    links.join(File::SEPARATOR).html_safe
  end

  def submission_tree_modification_date(date)
    if date.present?
      iso_time(date)
    else
      content_tag(:em, "not yet created")
    end
  end

  def submission_tree_submitter(submitter)
    if submitter.present?
      submitter.fullname
    else
      content_tag(:em, "N/A")
    end
  end
end
