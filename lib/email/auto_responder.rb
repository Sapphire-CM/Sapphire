$mail_config = YAML.load_file("#{Rails.root}/config/mail.yml").symbolize_keys

Mail.defaults do
  retriever_method :imap,
    address: $mail_config[:address],
    port: $mail_config[:port],
    enable_ssl: $mail_config[:enable_ssl],
    authentication: $mail_config[:authentication],
    user_name: $mail_config[:user_name],
    password: $mail_config[:password]
end

def deliver_mail(args)
  Mail.deliver do
    from $mail_config[:from_address]
    to args[:to]
    reply_to args[:reply_to]
    subject args[:subject]

    content_type 'text/plain; charset=utf-8'
    body args[:body]
  end
end

def new_mails
  mails = Mail.all delete_after_find: true
  mails.each do |mail|
    filename = "#{mail.date.parameterize}_#{mail.message_id.parameterize}.eml"
    filename = File.join('emails', filename)
    File.open(filename, 'w') do |f|
      f.write(mail.to_s)
    end
  end
  mails
end

def process_email(mail)
  begin
    mn = /inm-ws20[\d]{2}-t.-ex31-(.*)-(.*)-([\d]{7})/.match(mail.subject)[3]
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
      reply_to: tutors[tutorial_group_index][:email],
      subject: '[INM] Ex3.1: Web Research Topic',
      body: email_body)

    Rails.logger.info "AutoResponder: Sent email to #{student.fullname}, #{student.matriculation_number}."
  rescue
    Rails.logger.error "AutoResponder: Error with email #{mail.message_id}. No email sent."
    # binding.pry
  end
end

load 'lib/email/email_text.rb'

load 'persistent/auto_responder_paper_data.rb'
