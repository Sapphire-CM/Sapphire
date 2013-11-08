def execute(mail)
  # mn = /inm-ws20[\d]{2}-t.-ex31-(.*)-(.*)-([\d]{7})/.match(mail.subject)[3]
  mn = /([\d]{7})/.match(mail.subject)[0]
  raise "matriculation_number not found in email subject: '#{mail.subject}'" unless mn

  student = Account.all.where{matriculation_number == my{mn}}.first
  raise "student not found in database" unless student

  tutorial_group = student.student_registrations.last.student_group.tutorial_group
  raise "tutorial_group not found in database" unless tutorial_group

  files = []
  mail.attachments.each do |attachment|
    file = "emails/style_sheets/inm-ws2013-ex5-#{tutorial_group.title.downcase}-#{student.surname.downcase.parameterize}-#{student.forename.downcase.parameterize}-#{student.matriculation_number}/#{attachment.filename}"
    FileUtils.mkdir_p File.dirname(file)

    File.open(file, 'w') do |f|
      f.write attachment.body.decoded.force_encoding('utf-8')
    end

    files << [attachment.filename, File.size(file)]
  end




  email_body = create_email_text tutorial_group, files
  deliver_mail(
    to: mail.from,
    bcc: tutorial_group.tutor.email,
    subject: '[INM] Ex5: Style Sheets Submission',
    body: email_body)

  Rails.logger.info "AutoResponder: Sent email to #{student.fullname}, #{student.matriculation_number}."
end

def create_email_text(tutorial_group, files)
  text = <<-EOF
Style Sheets Submission
-----------------------

You have submitted the following style sheets:

EOF

  text << if files.empty?
    " No files submitted. Are you sure you did everything correctly?"
  else
    files.map do |filename, size|
      "  #{filename}: #{size} bytes"
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
