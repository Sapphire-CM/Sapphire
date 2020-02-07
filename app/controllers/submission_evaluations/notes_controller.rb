class SubmissionEvaluations::NotesController < NotesController
  before_action :set_notable, :set_term

  def show
    render "notes/show"
  end

  private
  
  def set_notable
    @notable = SubmissionEvaluation.find(params[:submission_evaluation_id])

    authorize @notable
  end

  def set_term
    @term = @notable.submission.term
  end
end
  
