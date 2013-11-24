load 'persistent/auto_responder_paper_data.rb'

def execute(mail)
  mn = /([\d]{7})/.match(mail.subject)
  mn = mn[0] if mn
  raise "matriculation_number not found in email subject: '#{mail.subject}'" unless mn

  student = Account.all.where{matriculation_number == my{mn}}.first
  raise "student not found in database" unless student

  tutorial_group = student.student_registrations.last.student_group.tutorial_group
  raise "tutorial_group not found in database" unless tutorial_group

  tutorial_group_index = tutorial_group.term.tutorial_groups.index tutorial_group
  raise "tutorial_group_index not found in database" unless tutorial_group_index

  student_index = tutorial_group.students.index student
  raise "student_index not found in database" unless student_index

  famous_person = $famous_persons[tutorial_group_index][student_index % 5]

  email_body = create_email_text famous_person, tutorial_group, student, tutorial_group_index
  AutoResponderMailer.response(
    to: mail.from,
    bcc: tutorial_group.tutor.email,
    reply_to: $tutors[tutorial_group_index][:email],
    subject: '[INM] Ex3.1: Web Research Topic',
    body: email_body
  )

  base = base_name_schema % {
    term: tutorial_group.term.title.delete(' ').parameterize,
    exercise: 'ex3',
    tutorial_group: tutorial_group.title.parameterize,
    surname: student.surname.parameterize,
    forename: student.forename.parameterize,
    matriculation_number: student.matriculation_number.parameterize,
  }

  File.open("emails/success/#{base}.eml", 'w') do |f|
    f.write mail.to_s
  end

  Rails.logger.autoresponder.info """
    AutoResponder: Web Research: Sent email to #{student.fullname}, #{student.matriculation_number}
      Person: #{famous_person[:name]}
  """
end

def create_email_text(famous_person, tutorial_group, student, tutorial_group_index)

  text = <<-EOF
Web Research
------------

You should research into the following computer scientist:

#{famous_person[:name]}

  IEEE: #{famous_person[:ieee][:page_count]} pages, MD5: #{famous_person[:ieee][:hash]}
   ACM: #{famous_person[:acm][:page_count]} pages, MD5: #{famous_person[:acm][:hash]}

Before you start, read the detailed instructions at:

  http://courses.iicm.tugraz.at/inm/exercises/exer3.html

When you have finished your report and created your PDF file, you will
need to upload it to the following TU Graz Teach Center room:

  #{$tugtc_rooms[tutorial_group_index]}

Note that there is one room for each tutorial group.

EOF

text << "-- \n" + <<EOF
Good luck!
#{tutorial_group.tutor.forename} #{tutorial_group.title}
EOF

  text
end
