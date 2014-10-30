class TutorialGroupScopingService
  attr_accessor :params, :term, :current_account

  def initialize(params, term, current_account)
    @params = params
    @term = term
    @current_account = current_account
  end

  def current_tutorial_group
    if params[:tutorial_group_id].present?
      term.tutorial_groups.find(params[:tutorial_group_id])
    else
      current_account.tutorial_groups.where(term_id: term.id).first.presence || term.tutorial_groups.first
    end
  end
end
