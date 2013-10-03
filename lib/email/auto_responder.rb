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
    subject args[:subject]
    body args[:body]
  end
end

def new_mails
  mails = Mail.all delete_after_find: true
  mails.each do |mail|
    filename = File.join('emails', mail.message_id.parameterize + '.eml')
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
    deliver_mail to: mail.from, subject: 'Ex3.1 Sapphire Test', body: email_body
    # deliver_mail to: student.email, subject: 'Ex3.1 Sapphire Test', body: email_body

    Rails.logger.info "#{DateTime.now} Sent email to #{student.fullname}, #{student.matriculation_number}."
  rescue
    Rails.logger.error "#{DateTime.now} Error with email #{mail.message_id}. No email sent."
    # binding.pry
  end
end

class FamousPerson
  attr_accessor :fullname, :acm_paper, :ieee_paper

  def initialize(fullname, acm_paper, ieee_paper)
    @fullname = fullname
    @acm_paper = acm_paper
    @ieee_paper = ieee_paper
  end
end

class Paper
  attr_accessor :page_count, :hash

  def initialize(page_count, hash)
    @page_count = page_count
    @hash = hash
  end
end

load 'lib/email/email_text.rb'

load 'persistent/auto_responder_paper_data.rb'
