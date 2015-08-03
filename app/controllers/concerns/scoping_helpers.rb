module ScopingHelpers
  extend ActiveSupport::Concern

  private

  def scoped_submissions(tutorial_group, submissions)
    scoped_submissions = submissions.order(submitted_at: :desc)

    case params[:submission_scope]
    when 'unmatched'
      scoped_submissions.unmatched
    when 'all'
      scoped_submissions
    else
      if tutorial_group.present?
        scoped_submissions.for_tutorial_group(tutorial_group)
      else
        scoped_submissions
      end
    end
  end

  def current_tutorial_group(term)
    if params[:tutorial_group_id].present?
      term.tutorial_groups.find(params[:tutorial_group_id])
    else
      current_account.tutorial_groups.ordered_by_title.where(term_id: term.id).first.presence || term.tutorial_groups.ordered_by_title.first
    end
  end
end
