# Do not log queries if we are not debugging specific specs
ActiveRecord::Base.logger = nil if ENV['DISABLE_LOGGING'].blank? && ARGV.empty?