require 'faker'

puts "Creating Accounts..."

accounts = Account.create! [
  { email: 'tutor@example.com',    forename: Faker::Name.first_name, surname: Faker::Name.last_name, password: 'testing' },
  { email: 'lecturer@example.com', forename: Faker::Name.first_name, surname: Faker::Name.last_name, password: 'testing' },
  { email: 'admin@example.com',    forename: Faker::Name.first_name, surname: Faker::Name.last_name, password: 'testing', admin: true },
]
student_account_attributes = 8.times.map do |i|
  {
    email: "student#{i}@testing",
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

puts "Creating a Term for that Course..."
terms = Term.create! [
  { title: "Term #{Time.now.year}",     course: course }
]
puts "Done!"

puts "Creating Tutorial and Student Groups..."
tutorial_groups = [
  {title: "T1", description: "First tutorial group"},
  {title: "T2", description: "Second tutorial group"}
].map {|tg_hash| tg = TutorialGroup.new(tg_hash); tg.term = course.terms.last; tg}
tutorial_groups.each {|tg| tg.save}

student_groups = [
  {title: "G1"},
  {title: "G2"},
  {title: "G3"},
  {title: "G4"}
].map {|sg_hash| sg = StudentGroup.new(sg_hash); sg.term = course.terms.last; sg}

student_groups.in_groups_of(student_groups.size / tutorial_groups.size).each.with_index do |groups, i|
  tg = tutorial_groups[i]
  groups.each do |sg|
    sg.tutorial_group = tg
    sg.save
  end
end
puts "Done!"

puts "Registering Accounts..."
TermRegistration.create! account: accounts[0], term: course.terms.last, role: Roles::TUTOR, tutorial_group: tutorial_groups.first
TermRegistration.create! account: accounts[1], term: course.terms.last, role: Roles::LECTURER

student_accounts.in_groups_of(student_accounts.size / student_groups.size).each.with_index do |student_group, i|
  sg = student_groups[i]
  student_group.each do |acc|
    TermRegistration.create! account: acc, term: course.terms.last, role: Roles::STUDENT, student_group: sg, tutorial_group: sg.tutorial_group
  end
end
puts "Done!"

puts "Creating Exercises..."
exercises = Exercise.create! [
  { title: 'Ex 1: Initial Report',        term: course.terms.last, group_submission: true },
  { title: 'Ex 2: Practical Assignment',  term: course.terms.last, group_submission: true },
  { title: 'Ex 3: Second Report',         term: course.terms.last, group_submission: true },
  { title: 'Ex 4: Final Report',          term: course.terms.last, group_submission: true },
  { title: 'Final Exam',                  term: course.terms.last, group_submission: false }
]
Exercise.all.map{ |obj| obj.row_order_position = :last; obj.save }
puts "Done!"

puts "Creating Rating Groups and Ratings for the first Exercise..."
rating_groups = [
  {title: "Introduction",  enable_range_points: true, points: 2, max_points:2,  min_points:0, global: false},
  {title: "First Section", enable_range_points: true, points: 10, max_points:10, min_points:0, global: false},
  {title: "Formatting and Miscellaneous", enable_range_points: true, points:0, max_points:5, min_points:-20, global: true}
].map {|rg_hash| rg = RatingGroup.new(rg_hash); rg.exercise = exercises.first; rg}
rating_groups.each {|rg| rg.save }

introduction_ratings = [
  {title: "missing", value: -100, type: "Ratings::FixedPercentageDeductionRating"},
  {title: "incorrect", value: -1, type: "Ratings::FixedPointsDeductionRating"}
].map {|r_hash| r = Rating.new(r_hash); r.rating_group = rating_groups[0]; r}
introduction_ratings.each {|r| r.save }

first_section_ratings = [
  {title: "missing", value: -100, type: "Ratings::FixedPercentageDeductionRating"},
  {title: "incorrect", value: -2, type: "Ratings::FixedPointsDeductionRating"},
  {title: "# bullet points missing", value: -1, multiplication_factor: 2, type: "Ratings::PerItemPointsDeductionRating"},
].map {|r_hash| r = Rating.new(r_hash); r.rating_group = rating_groups[1]; r}
first_section_ratings.each {|r| r.save }

miscellaneous_ratings = [
  {title: "too late for the assignment interview", value: -100, type: "Ratings::FixedPercentageDeductionRating"},
  {title: "not valid html in report", value: -1, multiplication_factor: -1, min_value: -5, max_value:0, type: "Ratings::VariablePointsDeductionRating"},
  {title: "bonus: very good report", value: 1, multiplication_factor: 1, min_value: 0, max_value: 5, type: "Ratings::VariableBonusPointsRating"},
].map {|r_hash| r = Rating.new(r_hash); r.rating_group = rating_groups[2]; r}
miscellaneous_ratings.each {|r| r.save }

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
