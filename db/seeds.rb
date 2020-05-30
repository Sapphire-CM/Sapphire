require 'faker'

Faker::Config.random = Random.new(42)

puts "Creating Accounts..."

accounts = Account.create! [
  { email: 'tutor@example.com',    forename: Faker::Name.first_name, surname: Faker::Name.last_name, password: 'testing' },
  { email: 'lecturer@example.com', forename: Faker::Name.first_name, surname: Faker::Name.last_name, password: 'testing' },
  { email: 'admin@example.com',    forename: Faker::Name.first_name, surname: Faker::Name.last_name, password: 'testing', admin: true },
]
student_account_attributes = 8.times.map do |i| {
    email: "student#{i}@example.com",
    forename: Faker::Name.first_name,
    surname: Faker::Name.last_name,
    matriculation_number: "123456#{i.to_s.rjust(2, '0')}",
    password: 'testing'
  }
end
student_accounts = Account.create!(student_account_attributes)
puts "Done!"

puts "Creating a Course..."
course = Course.create!({ title: 'Test Course', locked: false })
puts "Done!"

puts "Creating Terms for that Course..."
terms = Term.create! [
  { title: "Term #{Time.now.year - 1}", course: course },
  { title: "Term #{Time.now.year}",     course: course }
]
puts "Done!"

puts "Creating Tutorial and Student Groups..."
tutorial_groups_attributes = [
  {title: "T1", description: "First tutorial group"},
  {title: "T2", description: "Second tutorial group"}
].map { |attributes| attributes.merge(term: terms.last) }
tutorial_groups = TutorialGroup.create!(tutorial_groups_attributes)

student_groups_attributes = 4.times.map do |i| {
  title: "G#{i}",
  term: terms.last
}
end
student_groups_attributes.in_groups_of(student_groups_attributes.size / tutorial_groups.size).each.with_index do |groups, i|
  groups.map { |student_group_attrs| student_group_attrs.merge!(tutorial_group: tutorial_groups[i]) }
end
student_groups = StudentGroup.create!(student_groups_attributes)
puts "Done!"

puts "Registering Accounts..."
TermRegistration.create! account: accounts[0], term: terms.last, role: Roles::TUTOR, tutorial_group: tutorial_groups.first
TermRegistration.create! account: accounts[1], term: terms.last, role: Roles::LECTURER

student_term_registration_attributes = student_accounts.in_groups_of(student_accounts.size / student_groups.size).flat_map.with_index do |student_accounts, i|
  student_group = student_groups[i]
  tutorial_group = student_group.tutorial_group

  student_accounts.map do |student_account|
    { account: student_account, term: student_group.term, role: Roles::STUDENT, student_group: student_group, tutorial_group: tutorial_group }
  end
end
student_term_registrations = TermRegistration.create!(student_term_registration_attributes)

puts "Done!"

puts "Creating Exercises..."
exercises = Exercise.create! [
  { title: 'Ex 1: Initial Report',        term: terms.last, group_submission: true },
  { title: 'Ex 2: Practical Assignment',  term: terms.last, group_submission: true },
  { title: 'Ex 3: Second Report',         term: terms.last, group_submission: true },
  { title: 'Ex 4: Final Report',          term: terms.last, group_submission: true },
  { title: 'Final Exam',                  term: terms.last, group_submission: false }
]
Exercise.all.map{ |obj| obj.row_order_position = :last; obj.save }
puts "Done!"

puts "Creating Rating Groups and Ratings for #{exercises.first.title}..."
rating_groups_attributes = [
  {title: "Introduction",  enable_range_points: true, points: 2, max_points:2,  min_points:0, global: false},
  {title: "First Section", enable_range_points: true, points: 10, max_points:10, min_points:0, global: false},
  {title: "Formatting and Miscellaneous", enable_range_points: true, points:0, max_points:5, min_points:-20, global: true}
].map {|attributes| attributes.merge(exercise: exercises.first) }
rating_groups = RatingGroup.create(rating_groups_attributes)

introduction_ratings_attributes = [
  {title: "missing", value: -100, type: "Ratings::FixedPercentageDeductionRating"},
  {title: "incorrect", value: -1, type: "Ratings::FixedPointsDeductionRating"}
].map {|attributes| attributes.merge(rating_group: rating_groups[0])}
introduction_ratings = Rating.create(introduction_ratings_attributes)

first_section_ratings_attributes = [
  {title: "missing", value: -100, type: "Ratings::FixedPercentageDeductionRating"},
  {title: "incorrect", value: -2, type: "Ratings::FixedPointsDeductionRating"},
  {title: "# bullet points missing", value: -1, multiplication_factor: 2, type: "Ratings::PerItemPointsDeductionRating"},
].map {|attributes| attributes.merge(rating_group: rating_groups[1])}
first_section_ratings = Rating.create(first_section_ratings_attributes)

miscellaneous_ratings_attributes = [
  {title: "too late for the assignment interview", value: -100, type: "Ratings::FixedPercentageDeductionRating"},
  {title: "not valid html in report", value: -1, multiplication_factor: -1, min_value: -5, max_value:0, type: "Ratings::VariablePointsDeductionRating"},
  {title: "bonus: very good report", value: 1, multiplication_factor: 1, min_value: 0, max_value: 5, type: "Ratings::VariableBonusPointsRating"},
].map {|attributes| attributes.merge(rating_group: rating_groups[2])}
miscellaneous_ratings = Rating.create(miscellaneous_ratings_attributes)

puts "Done!"

puts "Creating a Submission for Student Group #{student_groups.first.title}"
SubmissionCreationService.new_student_submission(student_accounts.first, exercises.first).save
puts "Done!\n"

puts <<-MESSAGE
You are now good to go! You may start the server with:
$ rails server
and:
$ bundle exec sidekiq

Open your browser at 'localhost:3000' and login with:
 Email:'{admin,lecturer,tutor,student}@example.com'
 Password:'testing'

Note: The Email prefix will put you into the respective role,
      e.g. use 'student@example.com' to have a look at how students will see Sapphire.
MESSAGE
