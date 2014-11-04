class WebsiteFetcherWorker
  include Sidekiq::Worker

  def perform(service_id, term_registration_id)
    service = Service.find(service_id)
    term = service.exercise.term
    term_registration = term.term_registrations.find(term_registration_id)

    service.fetch_for_term_registration(term_registration)
  end
end
