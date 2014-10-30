class SubmissionScopingService
  attr_accessor :current_account, :params, :tutorial_group

  def initialize(params, tutorial_group)
    @params = params
    @tutorial_group = tutorial_group
  end

  def scoped_submissions(submissions)
    scoped_submissions = submissions

    scoped_submissions = submissions.order(submitted_at: :desc)
    case params[:submission_scope]
    when "unmatched"
      scoped_submissions.unmatched
    when "all"
      scoped_submissions
    else
      if tutorial_group.present?
        scoped_submissions.for_tutorial_group(tutorial_group)
      else
        scoped_submissions
      end
    end
  end
end
