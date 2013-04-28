class SubmissionsController < TermResourceController
  def index
    @submissions = current_term.submissions
  end  
  
  def show
    @submission = current_term.submissions.find(params[:id])
  end
end
