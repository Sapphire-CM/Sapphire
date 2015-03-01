module TutorialGroupContext
  extend ActiveSupport::Concern
  include TermContext


  protected
  def current_tutorial_group
    @tutorial_group
  end

  private
  def fetch_tutorial_group
    @tutorial_group = current_term.tutorial_groups.find(params[:tutorial_group_id])
  end

  included do
    before_action :fetch_tutorial_group
    helper_method :current_tutorial_group
  end
end
