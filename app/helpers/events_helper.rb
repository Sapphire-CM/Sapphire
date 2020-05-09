module EventsHelper
  def event_box(event, cache_identifier = nil, &block)
    fail ArgumentError.new('No block given') unless block_given?

    render 'events/event', content: capture(event, &block), event: event, css_classes: "event event-#{event.class.to_s.demodulize.downcase}", cache_identifier: cache_identifier
  end

  def comment_event_index(event)
    if policy(Comment.new(term: @term)).create?
      link_to event.exercise_title, polymorphic_path(event.subject_type.underscore, id: event.subject_id)
    else
      link_to event.exercise_title, term_result_path(term: event.term, id: event.subject.submission.exercise.id)
    end
  end
end
