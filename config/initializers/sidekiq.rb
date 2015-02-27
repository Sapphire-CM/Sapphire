Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'Sapphire'}
end

Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'Sapphire' }
end
