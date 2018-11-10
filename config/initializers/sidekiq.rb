default_redis_options = {
  namespace: "sapphire_#{Rails.env}_sidekiq",
  size: 27
}

Sidekiq.configure_server do |config|
  config.redis = default_redis_options
end

Sidekiq.configure_client do |config|
  config.redis = default_redis_options
end
