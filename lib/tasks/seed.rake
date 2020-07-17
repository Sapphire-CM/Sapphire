namespace :development do
  desc 'Seeds a development database. This resets the "Test Course"'
  task :seed => :environment do
    raise "This should not be run in production!" if Rails.env.production?

    if ActiveRecord::Base.connection.table_exists? 'courses'
      course = Course.find_by_title('Test Course')
      course.destroy if course.present?
    end

    if ActiveRecord::Base.connection.table_exists? 'accounts'
      Account.where("email LIKE ?", "%@example.com").destroy_all
    end

    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
  end
end
