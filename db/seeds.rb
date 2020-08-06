require 'faker'
require File.join File.dirname(__FILE__), 'seeds_config.rb'

$stdout.sync = true

if ENV["RANDOMIZED_PASSWORDS"] == "true"
  passwords = Array.new(STUDENT_ACCOUNTS + 3) { Faker::Number.number(digits: 8) }
else
  passwords = Array.new(STUDENT_ACCOUNTS + 3) { "testing" }
end

Faker::Config.random = Random.new(42)

print "Creating Accounts... "

accounts = Account.create! [
  { email: 'tutor@example.com',    forename: Faker::Name.first_name, surname: Faker::Name.last_name, password: passwords[0] },
  { email: 'lecturer@example.com', forename: Faker::Name.first_name, surname: Faker::Name.last_name, password: passwords[1] },
  { email: 'admin@example.com',    forename: Faker::Name.first_name, surname: Faker::Name.last_name, password: passwords[2], admin: true },
]
student_account_attributes = STUDENT_ACCOUNTS.times.map do |i| {
    email: "student#{i}@example.com",
    forename: Faker::Name.first_name,
    surname: Faker::Name.last_name,
    matriculation_number: "1234#{i.to_s.rjust(4, '0')}",
    password: passwords[i + 3]
  }
end
student_accounts = Account.create!(student_account_attributes)
puts "Done!"

print "Creating a Course... "
course = Course.create!({ title: 'Test Course', locked: false })
puts "Done!"

print "Creating Terms for that Course... "
terms = Term.create! [
  { title: "Term #{Time.now.year - 1}", course: course },
  { title: "Term #{Time.now.year}",     course: course }
]
puts "Done!"

terms.each do |term|
  print "Creating Tutorial and Student Groups for #{term.title} ... "
  tutorial_groups_attributes = TUTORIAL_GROUPS.times.map do |i| {
    title: "T#{i + 1}",
    description: "#{(i + 1).ordinalize} tutorial group",
    term: term
  }
  end
  tutorial_groups = TutorialGroup.create!(tutorial_groups_attributes)

  student_groups_attributes = STUDENT_GROUPS.times.map do |i| {
    title: "G#{i + 1}",
    term: term
  }
  end
  student_groups_attributes.in_groups_of(student_groups_attributes.size / tutorial_groups.size).each.with_index do |groups, i|
    groups.map { |student_group_attrs| student_group_attrs.merge!(tutorial_group: tutorial_groups[i]) }
  end
  student_groups = StudentGroup.create!(student_groups_attributes)
  puts "Done!"

  print "Registering Accounts for #{term.title} ... "
  TermRegistration.create! account: accounts[0], term: term, role: Roles::TUTOR, tutorial_group: tutorial_groups.first
  TermRegistration.create! account: accounts[1], term: term, role: Roles::LECTURER

  student_term_registration_attributes = student_accounts.in_groups_of(student_accounts.size / student_groups.size).flat_map.with_index do |student_accounts, i|
    student_group = student_groups[i]
    tutorial_group = student_group.tutorial_group

    student_accounts.map do |student_account|
      { account: student_account, term: student_group.term, role: Roles::STUDENT, student_group: student_group, tutorial_group: tutorial_group }
    end
  end
  student_term_registrations = TermRegistration.create!(student_term_registration_attributes)

  puts "Done!"

  print "Creating Exercises for #{term.title} ... "
  exercises = Exercise.create! [
    { title: 'Ex 1: Initial Report',        term: term, group_submission: true, submission_viewer_identifier: "Ex4HTMLViewer" },
    { title: 'Ex 2: Practical Assignment',  term: term, group_submission: true },
    { title: 'Ex 3: Second Report',         term: term, group_submission: true },
    { title: 'Ex 4: Final Report',          term: term, group_submission: true },
    { title: 'Final Exam',                  term: term, group_submission: false }
  ]
  Exercise.all.map{ |obj| obj.row_order_position = :last; obj.save }
  puts "Done!"

  exercises.each do |exercise|
    print "Creating Rating Groups and Ratings for #{exercise.title}... "
    rating_groups_attributes = [
      {title: "Introduction",  enable_range_points: true, points: 2, max_points:2,  min_points:0, global: false},
      {title: "First Section", enable_range_points: true, points: 10, max_points:10, min_points:0, global: false},
      {title: "Formatting and Miscellaneous", enable_range_points: true, points:0, max_points:5, min_points:-20, global: true}
    ].map {|attributes| attributes.merge(exercise: exercise) }
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
  end

  print "Creating a Submission for Student Group #{student_groups.first.title}... "
  submission_creation_service = SubmissionCreationService.new_student_submission(student_accounts.first, exercises.first)
  submission_creation_service.save
  data_directory = File.join(Rails.root, 'db', 'data')
  Dir.foreach(data_directory) do |file|
    next if file == '.' or file == '..'
    upload_file = File.join(Rails.root, 'tmp', file)
    FileUtils.cp File.join(data_directory, file), upload_file

    submission_upload = SubmissionUpload.new(file: File.open(upload_file), path: "", submitter: student_accounts.first, submission: submission_creation_service.submission).save
  end
  puts "Done!\n"
end
