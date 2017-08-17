module EventsHelper
  def event_box(event, cache_identifier = nil, &block)
    fail ArgumentError.new('No block given') unless block_given?

    render 'events/event', content: capture(event, &block), event: event, css_classes: "event event-#{event.class.to_s.demodulize.downcase}", cache_identifier: cache_identifier
	 
  end
end
