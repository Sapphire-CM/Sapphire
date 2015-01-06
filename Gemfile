source 'https://rubygems.org'

gem 'rails', '4.0.6'

gem 'pg'                          # PostgreSQL database connector

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
gem 'email_validator'             # provides ActiveRecord validation for email addresses

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

gem 'writeexcel'                  # exporting excel spreadsheets
gem 'multi_logger'                # custom log files

group :development do
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-pow'
  gem 'guard-sidekiq'

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
  gem 'letter_opener_web'   # local email sender to HTML pages
  gem 'traceroute'          # detects unused routes and actions
  # gem 'brakeman'            # common security problems checker
  # gem 'bullet'              # logs and supposes optimizations for db queries
  # gem 'sextant'             # route /rails/routes for displaying all routes

  gem 'capistrano', '~> 3.2.0' # deployment via SSH
  gem 'capistrano-rvm'         # capistrano plugin for RVM
  gem 'capistrano-rails'       # capistrano plugin for Rails
  gem 'capistrano-sidekiq'     # capistrano plugin for Sidekiq
  gem 'capistrano-passenger'   # capistrano plugin for Passenger
end

group :test do
  gem 'cucumber'
  gem 'cucumber-rails', require: false

  gem 'rspec-rails'

  gem 'guard-rspec'
  gem 'guard-cucumber'

  gem 'shoulda-matchers'

  gem 'terminal-notifier'
  gem 'terminal-notifier-guard'

  gem 'factory_girl_rails'
  gem 'database_cleaner'

  gem 'simplecov'                 # test-coverage reports
  gem 'simplecov-html', github: 'Kriechi/simplecov-html', branch: 'fix-list-hiding' # html formatting of simplecov results

  gem 'capybara'
  gem 'poltergeist'               # PhantomJS, headless Webkit
  # gem 'selenium-webdriver'      # Selenium, Firefox webdriver
  # gem 'capybara-webkit'         # Webkit headless webdriver
end

group :development, :test do
  gem 'mysql2'                    # MySQL database connector
  gem 'sqlite3'                   # sqlite3 database connector
end
