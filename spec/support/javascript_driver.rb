require 'capybara/poltergeist'

# Capybara.register_driver :poltergeist do |app|
#   log_file = File.new(File.join(Rails.root, 'log', 'phantomjs_logger.log'), 'w')

#   options = {
#     logger: log_file
#   }

#   Capybara::Poltergeist::Driver.new(app, options)
# end

Capybara.javascript_driver = :poltergeist
