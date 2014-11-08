source 'https://rubygems.org'

gem 'rails', '~> 4.0.0'

gem 'jquery-rails'                # Use jquery as the JavaScript library
gem 'jquery-ui-rails'
gem 'jquery-mousewheel-rails'     # jquery MouseWheel support

gem 'simple_form', '~> 3.0'       # forms
gem 'carrierwave'                 # fileuploads
gem 'squeel', '~> 1.1'            # easy DSL
gem 'draper'                      # decorators
gem 'kaminari'                    # pagination
gem 'flash_render'                # render method with notice/alerts
gem 'devise', '~> 3.2'            # user authentication
gem 'pundit'                      # authorization based on controller actions and policies
gem 'turbolinks'                  # Turbolinks makes following links in your web application faster
gem 'jquery-turbolinks'           # Turbolinks jquery plugin for DOM ready events
gem 'ranked-model'                # manages sort-position of ratings

gem 'compass-rails',   '~> 1.1'   # Compass intregration into assets-pipeline
gem 'sass-rails',      '~> 4.0'   # Use SCSS for stylesheets
gem 'coffee-rails',    '~> 4.0'   # Use CoffeeScript for .js.coffee assets and views
gem 'uglifier',        '>= 1.3'   # Use Uglifier as compressor for JavaScript assets
gem 'zurb-foundation', '~> 4.3.0'
gem 'foundation-icons-sass-rails', '~> 3.0'

gem 'remotipart', '~> 1.2'        # fileuploads via ajax

gem 'whenever'                    # cron tasks
gem 'nntp-client', github: 'matthee/Sapphire-NNTP'  # fetching newsgroup posts
gem 'mail'                        # fetching, delivering and parsing of emails

gem 'coderay'                     # doing code-highlighting for submission_assets
gem 'rails_autolink'              # autolinking submitted newsgroup-posts and emails
gem 'css_parser'                  # for parsing css files
gem 'mechanize'                   # grabing inm websites
gem 'nokogiri'                    # for parsing HTML-Files

gem 'cocoon'                      # for nested upload forms

gem 'sidekiq'                     # async jobs in background, used for imports
gem 'sinatra', '>= 1.3.0', :require => nil    # small rack framework, used for sidekiq ui

group :production do
  gem 'therubyracer'
  gem 'pg'                        # PostgreSQL database connector
end

group :development do
  gem 'guard'
  gem 'guard-pow'

  gem 'pry'
  gem 'pry-rails'

  gem 'pry-doc'
  gem 'pry-docmore'
  gem 'pry-stack_explorer'
  gem 'pry-rescue'
  gem 'pry-byebug'
  gem 'bond'
  gem 'jist'

  gem 'spring'                    # application preloader for development environments
  gem 'spring-commands-cucumber'  # adding cucumber command to spring
  gem 'spring-commands-rspec'     # adding rspec command to spring
  gem 'spring-commands-sidekiq'   # adding sidekiq command to spring

  gem 'thin'                # small development webserver
  gem 'awesome_print'       # nicley formatted object inspection
  gem 'better_errors'       # pretty error pages
  gem 'binding_of_caller'   # interactive shell within error pages
  gem 'rails-erd'           # Entity-Relation Diagrams of models
  gem 'quiet_assets'        # suppresses logging of assets files
  gem 'letter_opener'       # local email sender to HTML pages
  # gem 'brakeman'            # common security problems checker
  # gem 'bullet'              # logs and supposes optimizations for db queries
  # gem 'sextant'             # route /rails/routes for displaying all routes

  gem 'capistrano', '~> 3.0' # deployment via ssh
  gem 'capistrano-rvm'       # capistrano plugin for rvm
  gem 'capistrano-rails'     # capistrano plugin for rails
  gem 'capistrano-sidekiq'   # capistrano plugin for sidekiq
end

group :development, :test do
  gem 'sqlite3'
  gem 'mysql2'
  gem 'pg'
  gem 'cucumber'
  gem 'cucumber-rails', require:false
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'terminal-notifier-guard'
  gem 'shoulda'
  gem 'shoulda-matchers-pundit'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'simplecov', '~> 0.7.1'     # test-coverage reports (upgrade when https://github.com/colszowka/simplecov/issues/281 is resolved)
  gem 'poltergeist'               # PhantomJS, headless Webkit
  # gem 'selenium-webdriver'      # Selenium, Firefox webdriver
  # gem 'capybara-webkit'         # Webkit headless webdriver
end
