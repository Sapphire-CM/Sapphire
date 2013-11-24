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

  base = base_name_schema % {
    term: tutorial_group.term.title.delete(' ').parameterize,
    exercise: 'ex5',
    tutorial_group: tutorial_group.title.parameterize,
    surname: student.surname.parameterize,
    forename: student.forename.parameterize,
    matriculation_number: student.matriculation_number.parameterize,
  }

  files = []
  mail.attachments.each do |attachment|
    file = "emails/success/style_sheets/#{base}/#{attachment.filename}"
    FileUtils.mkdir_p File.dirname(file)

    File.open(file, 'w') do |f|
      f.write attachment.body.decoded.force_encoding('utf-8')
    end

    files << [attachment.filename, File.size(file).to_s]
  end

  email_body = create_email_text tutorial_group, files
  AutoResponderMailer.response(
    to: mail.from,
    bcc: tutorial_group.tutor.email,
    reply_to: $tutors[tutorial_group_index][:email],
    subject: '[INM] Ex5: Style Sheets Submission',
    body: email_body
  )

  File.open("emails/success/#{base}.eml", 'w') do |f|
    f.write mail.to_s
  end

  Rails.logger.autoresponder.info """
    AutoResponder: Style Sheets: Sent email to #{student.fullname}, #{student.matriculation_number}
      Submitted files: #{files.count}
  """
end

def create_email_text(tutorial_group, files)
  max_filename = files.map { |filename, size| filename.length }.max
  max_size = files.map { |filename, size| size.length  }.max

  text = <<-EOF
Style Sheets Submission
-----------------------

You have submitted #{files.count} #{'file'.pluralize files.count}:

EOF

  text << if files.empty?
    "  *no files submitted* - are you sure you did everything correctly?"
  else
    files.map do |filename, size|
      "  #{(filename + ":").ljust(max_filename + 1)} #{size.rjust(max_size)} #{'byte'.pluralize size.to_i}"
    end.join "\n"
  end

  text << <<-EOF


Thank you!

EOF

  text << "-- \n" + <<EOF
#{tutorial_group.tutor.forename} #{tutorial_group.title}
EOF

  text
end
