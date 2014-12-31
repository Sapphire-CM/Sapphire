class ServiceJob < ActiveJob::Base
  queue_as :default

  def perform(service_id)
    service = Service.find(service_id)

    service.perform!
  end
end
