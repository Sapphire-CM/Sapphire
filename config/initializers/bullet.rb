if defined?(Bullet) && Rails.env == "development"
  Bullet.enable = true
  Bullet.bullet_logger = true
  # Bullet.alert = true
end