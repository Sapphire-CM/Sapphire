require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Sapphire
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/lib/sapphire)
    config.autoload_paths += %W(#{config.root}/app/viewmodels)
    config.autoload_paths += %W(#{config.root}/app/workers)
    config.autoload_paths += %W(#{config.root}/app/models/services)
    config.autoload_paths += %W(#{config.root}/app/models/ratings)
    config.autoload_paths += %W(#{config.root}/app/models/evaluations)
    config.autoload_paths += %W(#{config.root}/app/models/exports)
    config.autoload_paths += %W(#{config.root}/lib/scanners)
    config.autoload_paths += %W(#{config.root}/app/services)

    config.time_zone = 'Vienna'

    config.encoding = "utf-8"

    config.active_support.escape_html_entities_in_json = true

    config.i18n.enforce_available_locales = true

    config.assets.precompile += %w( jquery.js )

    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end
  end
end
