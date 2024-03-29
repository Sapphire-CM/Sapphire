source 'https://rubygems.org'

gem 'rails', '~>5.0.7'

gem 'pg'               # PostgreSQL database connector

gem 'jquery-rails'                # Use jquery as the JavaScript library
gem 'jquery-ui-rails'
gem 'jquery-mousewheel-rails'     # jquery MouseWheel support

gem 'd3-rails', "~> 4.13.0"

gem 'simple_form', '~> 3.0'       # forms
gem 'devise',      '~> 4.0'       # user authentication
gem 'carrierwave'                 # fileuploads
gem 'kaminari'                    # pagination
gem 'pundit'                      # authorization based on controller actions and policies
gem 'turbolinks', "~>2.5.3"                  # Turbolinks makes following links in your web application faster
gem 'jquery-turbolinks'           # Turbolinks jquery plugin for DOM ready events
gem 'ranked-model'                # manages sort-position of ratings
gem 'email_validator'             # provides ActiveRecord validation for email addresses
gem 'charlock_holmes'             # encoding detection for submitted submission assets

gem 'sass-rails'                  # Use SCSS for stylesheets
gem 'coffee-rails', "~> 4.0"      # Use CoffeeScript for .js.coffee assets and views
gem 'uglifier'                    # Use Uglifier as compressor for JavaScript assets
gem 'foundation-icons-sass-rails', '~> 3.0'

gem 'remotipart', '~> 1.2'        # fileuploads via ajax
gem 'jbuilder'                    # rendering .jbuilder templates (json responses)

gem 'whenever'                    # cron tasks
gem 'nntp-client', github: 'matthee/Sapphire-NNTP'  # fetching newsgroup posts
gem 'mail'                        # fetching, delivering and parsing of emails

gem 'coderay'                     # doing code-highlighting for submission_assets

gem 'css_parser'                  # for parsing css files
gem 'mechanize'                   # grabing inm websites
gem 'nokogiri'                    # for parsing HTML-Files
gem 'rubyzip'                     # handling submission ZIP archives
gem 'kramdown'

gem 'cocoon'                      # for nested upload forms
gem 'dropzonejs-rails', "~> 0.7.0" # Drag and drop support for file uploads

gem 'sidekiq', '~>5.2.10'        # async jobs in background, used for imports

gem 'writeexcel'                  # exporting excel spreadsheets
gem 'multi_logger'                # custom log files

gem 'exception_notification'      # send out emails if an unhandled exception occours
gem 'redis-namespace'             # namespaces for sidekiq queues

gem 'autoprefixer-rails'          # automatically add vendor prefixes to CSS

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

group :development, :test do
  gem 'pry'
  gem 'pry-rails'

  gem 'pry-doc'
  gem 'pry-docmore'
  gem 'pry-stack_explorer'
  gem 'pry-rescue'
  gem 'pry-byebug'
  gem 'bond'
  gem 'jist'

  gem 'mysql2'                    # MySQL database connector
  gem 'sqlite3', "~>1.3.0"        # sqlite3 database connector
  gem 'parallel_tests'            # Parallelize Tests

  gem 'faker'                     # fake data for seeds
end

group :development do
  gem 'foreman'

  gem 'active_record-annotate'    # adds the corresponding schema.rb snippet to each model file
  gem 'puma'                # small development webserver
  gem 'awesome_print'       # nicley formatted object inspection
  gem 'better_errors'       # pretty error pages
  gem 'binding_of_caller'   # interactive shell within error pages
  gem 'rails-erd'           # Entity-Relation Diagrams of models
  gem 'letter_opener_web'   # local email sender to HTML pages
  gem 'traceroute'          # detects unused routes and actions
  gem 'consistency_fail'    # detects missing unique indexes
  gem 'rubocop'                   # Ruby coding style checker and enforcer
  gem 'rubocop-rspec'             # RuboCop plugin for RSpec files
  # gem 'brakeman'            # common security problems checker
  # gem 'bullet'              # logs and supposes optimizations for db queries
  # gem 'sextant'             # route /rails/routes for displaying all routes

  gem 'capistrano', '~> 3.4.0' # deployment via SSH
  gem 'capistrano-rbenv'       # capistrano plugin for rbenv
  gem 'capistrano-rails'       # capistrano plugin for Rails
  gem 'capistrano-sidekiq'     # capistrano plugin for Sidekiq
  gem 'capistrano-passenger'   # capistrano plugin for Passenger

  gem 'ed25519'                # enable ed25519 support for net-ssh
  gem 'bcrypt_pbkdf'
end

group :test do
  gem 'rspec-rails'               # RSpec testing framework

  gem 'shoulda-matchers', '~> 3.1.1' # Nice RSpec matchers for many different common tasks

  gem 'factory_bot_rails'
  gem 'database_cleaner'

  gem 'simplecov'                 # test-coverage reports

  gem 'capybara'                  # feature test syntax enhancements
  gem 'capybara-screenshot'       # automatically generate screenshots for failing feature tests
  gem 'poltergeist'               # PhantomJS, headless Webkit

  # gem 'selenium-webdriver'      # Selenium, Firefox webdriver
  # gem 'capybara-webkit'         # Webkit headless webdriver

  gem 'timecop'                   # improved time handling during tests
  gem "rails-controller-testing", "~> 1.0" # extracted behaviour for controller testing
end

