class ResultPublicationService
  attr_reader :account, :exercise

  def initialize(account, exercise)
    @account = account
    @exercise = exercise
  end

  def publish!(result_publication)
    raise ArgumentError unless result_publication.exercise == exercise
    return if result_publication.published?

    result_publication.publish!
    create_publication_event!(result_publication)
    send_notifications!(result_publication)
  end

  def conceal!(result_publication)
    raise ArgumentError unless result_publication.exercise == exercise
    return if result_publication.concealed?

    result_publication.conceal!
    create_concealation_event!(result_publication)
  end

  def publish_all!
    exercise.result_publications.joins(:tutorial_group).merge(TutorialGroup.ordered_by_title).each do |result_publication|
      publish!(result_publication)
    end
  end

  def conceal_all!
    exercise.result_publications.joins(:tutorial_group).merge(TutorialGroup.ordered_by_title).each do |result_publication|
      conceal!(result_publication)
    end
  end

  private
  def term
    exercise.term
  end

  def create_publication_event!(result_publication)
    event_service.result_publication_published!(result_publication)
  end

  def create_concealation_event!(result_publication)
    event_service.result_publication_concealed!(result_publication)
  end

  def send_notifications!(result_publication)
    NotificationJob.result_publication_notifications(result_publication)
  end

  def event_service
    EventService.new(account, term)
  end
end
