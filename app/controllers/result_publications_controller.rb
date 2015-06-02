class ResultPublicationsController < ApplicationController
  include EventSourcing

  before_action :set_context

  def index
    authorize ResultPublication

    @result_publications = @exercise.result_publications
      .joins(:tutorial_group)
      .includes(tutorial_group: { tutor_term_registrations: :account })
  end

  def update
    @result_publication = @exercise.result_publications.find(params[:id])
    authorize @result_publication

    if @result_publication.update(result_publication_params)
      msg = if @result_publication.previous_changes.keys.include?('published')
        "Successfully #{@result_publication.published? ? 'published' : 'concealed'} results for #{@result_publication.exercise.title} for #{@result_publication.tutorial_group.title}"
      else
        'Successfully updated result publication'
      end

      track_update!(@result_publication)

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

  def track_update!(result_publication)
    if result_publication.previous_changes.keys.include?('published')
      if result_publication.published?
        event_service.result_publication_published!(result_publication)
      else
        event_service.result_publication_concealed!(result_publication)
      end

      NotificationJob.result_publication_notifications(result_publication)
    end
  end
end
