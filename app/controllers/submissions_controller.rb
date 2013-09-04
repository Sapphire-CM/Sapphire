class SubmissionsController < ApplicationController
  before_action :set_context

  def index
    @submissions = current_term.submissions
  end

  def show
    @submission = current_term.submissions.find(params[:id])
  end

  private
    def set_context
      raise
    end
end
