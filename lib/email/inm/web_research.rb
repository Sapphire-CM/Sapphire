load 'persistent/auto_responder_paper_data.rb'

def execute(mail)
  # mn = /inm-ws20[\d]{2}-t.-ex31-(.*)-(.*)-([\d]{7})/.match(mail.subject)[3]
  mn = /.*([\d]{7})$/.match(mail.subject)[3]
  throw NotFoundExeception unless mn

  student = Account.all.where{matriculation_number == my{mn}}.first
  throw NotFoundExeception unless student

  tutorial_group = student.student_registrations.last.student_group.tutorial_group
  throw NotFoundExeception unless tutorial_group

  tutorial_group_index = tutorial_group.term.tutorial_groups.index tutorial_group
  throw NotFoundExeception unless tutorial_group_index

  student_index = tutorial_group.students.index student
  throw NotFoundExeception unless student_index

  email_body = create_email_text tutorial_group_index, student_index
  deliver_mail(
    to: mail.from,
    reply_to: $tutors[tutorial_group_index][:email],
    subject: '[INM] Ex3.1: Web Research Topic',
    body: email_body)

  Rails.logger.info "AutoResponder: Sent email to #{student.fullname}, #{student.matriculation_number}."
end

def create_email_text(tutorial_group_index, student_index)
  famous_person = $famous_persons[tutorial_group_index][student_index % 5]

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
need to log in to your account on the Sapphire submission system:

  https://sapphire.iicm.tugraz.at/

and upload the PDF file before the corresponding deadline.

EOF

text << "-- \n" + <<EOF
Good luck!
#{$tutors[tutorial_group_index][:name]} T#{tutorial_group_index+1}
EOF

  text
end
