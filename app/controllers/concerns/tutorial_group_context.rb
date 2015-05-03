module TutorialGroupContext
  extend ActiveSupport::Concern

  included do
    include TermContext

    before_action :fetch_tutorial_group
    helper_method :current_tutorial_group
  end

  def current_tutorial_group
    @tutorial_group
  end

  private

  def fetch_tutorial_group
    id = params[:tutorial_group_id]
    @tutorial_group = current_term.tutorial_groups.find_by_id(id) if id
  end
end
