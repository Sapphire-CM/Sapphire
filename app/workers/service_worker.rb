class ServiceWorker
  include Sidekiq::Worker

  def perform(service_id)
    service = Service.find(service_id)

    service.perform!
  end
end