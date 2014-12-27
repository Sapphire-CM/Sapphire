class ResultPublicationsController < ApplicationController
  skip_after_action :verify_authorized, only: :index

  before_action :set_context

  def index
    @result_publications = @exercise.result_publications
      .joins(:tutorial_group)
      .includes(tutorial_group: {tutor_term_registrations: :account})
  end

  def update
    @result_publicaton = @exercise.result_publications.find(params[:id])
    authorize @result_publicaton

    if @result_publicaton.update(result_publication_params)
      msg = if @result_publicaton.previous_changes.keys.include?("published")
        "Successfully #{@result_publicaton.published? ? "published" : "concealed"} results for #{@result_publicaton.exercise.title} for #{@result_publicaton.tutorial_group.title}"
      else
        "Successfully updated result publication"
      end

      NotificationWorker.result_publication_notifications(@result_publicaton) if @result_publicaton.published?

      redirect_to exercise_result_publications_path(@exercise), notice: msg
    end
  end

  private

  def result_publication_params
    params.require(:result_publication).permit(:published)
  end

  def set_context
    @exercise = Exercise.find(params[:exercise_id])
    @term = @exercise.term
  end
end
