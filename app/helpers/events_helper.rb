module EventsHelper
  def event_box(event, &block)
    raise ArgumentError.new("No block given") unless block_given?

    render "events/event", content: capture(event, &block), event: event, css_classes: "event event-#{event.class.to_s.demodulize.downcase}"
  end
end
