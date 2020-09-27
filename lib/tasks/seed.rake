namespace :development do
  desc 'Seeds a development database. This resets the "Test Course"'
  task reseed: [:cleanup_seed_data, "db:seed"]

  task cleanup_seed_data: :environment do
    raise "This should not be run in production!" if Rails.env.production?

    course = Course.find_by(title: 'Test Course')
    course.destroy if course.present?

    Account.where("email LIKE ?", "%@example.com").destroy_all
  end
end
