module EventSourcing
  extend ActiveSupport::Concern

  def event_service
    term = respond_to?(:current_term) ? current_term : @term
    EventService.new(current_account, term)
  end
end
