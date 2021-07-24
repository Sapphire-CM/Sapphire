source 'https://rubygems.org'

gem 'rails', '=4.2.11.3'

gem 'pg', "~>0.15"                          # PostgreSQL database connector

gem 'jquery-rails'                # Use jquery as the JavaScript library
gem 'jquery-ui-rails'
gem 'jquery-mousewheel-rails'     # jquery MouseWheel support

gem 'd3-rails'

gem 'simple_form', '~> 3.0'       # forms
gem 'devise',      '~> 4.0'       # user authentication
gem 'squeel',      '~> 1.2'       # easy DSL
gem 'carrierwave'                 # fileuploads
gem 'kaminari'                    # pagination
gem 'pundit'                      # authorization based on controller actions and policies
gem 'turbolinks'                  # Turbolinks makes following links in your web application faster
gem 'jquery-turbolinks'           # Turbolinks jquery plugin for DOM ready events
gem 'ranked-model'                # manages sort-position of ratings
gem 'email_validator'             # provides ActiveRecord validation for email addresses
gem 'charlock_holmes'             # encoding detection for submitted submission assets

gem 'compass-rails',   '~> 2.0', '>= 2.0.2' # Compass intregration into assets-pipeline
gem 'sass-rails',      '~> 5.0'   # Use SCSS for stylesheets
gem 'coffee-rails',    '~> 4.0'   # Use CoffeeScript for .js.coffee assets and views
gem 'uglifier',        '>= 1.3'   # Use Uglifier as compressor for JavaScript assets
gem 'zurb-foundation', '~> 4.3.0'
gem 'foundation-icons-sass-rails', '~> 3.0'

gem 'remotipart', '~> 1.2'        # fileuploads via ajax
gem 'jbuilder'                    # rendering .jbuilder templates (json responses)

gem 'whenever'                    # cron tasks
gem 'nntp-client', github: 'matthee/Sapphire-NNTP'  # fetching newsgroup posts
gem 'mail'                        # fetching, delivering and parsing of emails

gem 'coderay'                     # doing code-highlighting for submission_assets
gem 'rails_autolink'              # autolinking submitted newsgroup-posts and emails
gem 'css_parser'                  # for parsing css files
gem 'mechanize'                   # grabing inm websites
gem 'nokogiri'                    # for parsing HTML-Files
gem 'rubyzip'                     # handling submission ZIP archives
gem 'kramdown'

gem 'cocoon'                      # for nested upload forms
gem 'dropzonejs-rails'            # Drag and drop support for file uploads

gem 'sidekiq', '~>5.2.3'          # async jobs in background, used for imports

gem 'writeexcel'                  # exporting excel spreadsheets
gem 'multi_logger'                # custom log files

gem 'exception_notification'      # send out emails if an unhandled exception occours
gem 'redis-namespace'             # namespaces for sidekiq queues

gem 'autoprefixer-rails'          # automatically add vendor prefixes to CSS

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
  gem 'sqlite3'                   # sqlite3 database connector
  gem 'parallel_tests'            # Parallelize Tests

  gem 'faker'                     # fake data for seeds
end

group :development do
  gem 'spring'                    # application preloader for development environments
  gem 'spring-commands-rspec'     # adding rspec command to spring
  gem 'spring-commands-sidekiq'   # adding sidekiq command to spring

  gem 'active_record-annotate'    # adds the corresponding schema.rb snippet to each model file
  # gem 'thin'                # small development webserver
  gem 'awesome_print'       # nicley formatted object inspection
  gem 'better_errors'       # pretty error pages
  gem 'binding_of_caller'   # interactive shell within error pages
  gem 'rails-erd'           # Entity-Relation Diagrams of models
  gem 'quiet_assets'        # suppresses logging of assets files
  gem 'letter_opener_web'   # local email sender to HTML pages
  gem 'traceroute'          # detects unused routes and actions
  gem 'consistency_fail'    # detects missing unique indexes
  gem 'rubocop'                   # Ruby coding style checker and enforcer
  gem 'rubocop-rspec'             # RuboCop plugin for RSpec files
  # gem 'brakeman'            # common security problems checker
  # gem 'bullet'              # logs and supposes optimizations for db queries
  # gem 'sextant'             # route /rails/routes for displaying all routes

  gem 'capistrano', '~> 3.4.0' # deployment via SSH
  gem 'capistrano-rbenv'         # capistrano plugin for RVM
  gem 'capistrano-rails'       # capistrano plugin for Rails
  gem 'capistrano-sidekiq'     # capistrano plugin for Sidekiq
  gem 'capistrano-passenger'   # capistrano plugin for Passenger

  gem 'ed25519'                # enable ed25519 support for net-ssh
  gem 'bcrypt_pbkdf'
end

group :test do
  gem 'rspec-rails'               # RSpec testing framework

  gem 'shoulda-matchers', '~> 3.1.1' # Nice RSpec matchers for many different common tasks

  gem 'factory_girl_rails'
  gem 'database_cleaner'

  gem 'simplecov'                 # test-coverage reports

  gem 'capybara'                  # feature test syntax enhancements
  gem 'capybara-screenshot'       # automatically generate screenshots for failing feature tests
  gem 'poltergeist'               # PhantomJS, headless Webkit

  # gem 'selenium-webdriver'      # Selenium, Firefox webdriver
  # gem 'capybara-webkit'         # Webkit headless webdriver

  gem 'timecop'                   # improved time handling during tests
end
