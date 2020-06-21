namespace :development do
  desc 'Seeds a development database. This resets the "Test Course"'
  task :seed => :environment do
    raise "This should not be run in production!" if Rails.env.production?

    if ActiveRecord::Base.connection.table_exists? 'courses'
      course = Course.find_by_title('Test Course')
      course.destroy if course.present?
    end

    if ActiveRecord::Base.connection.table_exists? 'accounts'
      new_emails = ["admin@example.com",
                    "lecturer@example.com",
                    "tutor@example.com"]
      student_emails = 8.times.map do |i|
                        "student#{i}@example.com"
                      end
      (new_emails | student_emails).each do |email|
        account = Account.find_by_email(email)
        account.destroy if account.present?
      end
    end

    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
  end
end
