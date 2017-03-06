Sidekiq.configure_server do |config|
  config.redis = { :namespace => "sapphire_#{Rails.env}_sidekiq"}
end

Sidekiq.configure_client do |config|
  config.redis = { :namespace => "sapphire_#{Rails.env}_sidekiq" }
end
