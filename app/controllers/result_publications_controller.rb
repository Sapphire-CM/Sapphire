class ResultPublicationsController < ApplicationController
  include EventSourcing

  before_action :set_context
  before_action :set_result_publication, only: [:publish, :conceal]

  def index
    authorize ResultPublicationPolicy.with(@term)

    @result_publications = @exercise.result_publications
      .joins(:tutorial_group)
      .includes(tutorial_group: { tutor_term_registrations: :account })
      .merge(TutorialGroup.ordered_by_title)
  end

  def publish
    result_publication_service.publish!(@result_publication)

    redirect_to exercise_result_publications_path(@exercise), notice: "Successfully published results for #{@exercise.title} for #{@result_publication.tutorial_group.title}"
  end

  def conceal
    result_publication_service.conceal!(@result_publication)

    redirect_to exercise_result_publications_path(@exercise), notice: "Successfully concealed results for #{@exercise.title} for #{@result_publication.tutorial_group.title}"
  end

  def publish_all
    authorize ResultPublicationPolicy.with(@term)

    result_publication_service.publish_all!

    redirect_to exercise_result_publications_path(@exercise), notice: "Successfully published all results for '#{@exercise.title}'"
  end

  def conceal_all
    authorize ResultPublicationPolicy.with(@term)

    result_publication_service.conceal_all!

    redirect_to exercise_result_publications_path(@exercise), notice: "Successfully concealed all results for '#{@exercise.title}'"
  end


  private
  def result_publication_params
    params.require(:result_publication).permit(:published)
  end

  def result_publication_service
    ResultPublicationService.new(current_account, @exercise)
  end

  def set_result_publication
    @result_publication = @exercise.result_publications.find(params[:id])

    authorize @result_publication
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
