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

FileUtils.mkdir_p 'emails/raw'
FileUtils.mkdir_p 'emails/response'
FileUtils.mkdir_p 'emails/success'
FileUtils.mkdir_p 'emails/failure'

def mail_filename(mail)
  "#{mail.date.to_s.parameterize}-#{mail.message_id.parameterize}.eml"
end

def base_name_schema
  'inm-%{term}-%{exercise}-%{tutorial_group}-%{surname}-%{forename}-%{matriculation_number}'
end

class AutoResponderMailer < ActionMailer::Base
  default from: $mail_config[:from_address]

  def response(args)
    message = mail(
      to: args[:to],
      reply_to: args[:reply_to],
      subject: args[:subject],
      body: args[:body]
    )

    message.charset = 'UTF-8'
    message.deliver

    File.open("emails/response/#{mail_filename message}", 'w') do |f|
      f.write(message.to_s)
    end
  end
end

def new_mails
  mails = Mail.all delete_after_find: true
  mails.each do |message|
    File.open("emails/raw/#{mail_filename message}", 'w') do |f|
      f.write(message.to_s)
    end
  end
  mails
end

def process_email(mail)
  begin
    execute mail
  rescue Exception => e
    File.open("emails/failure/#{mail_filename mail}", 'w') do |f|
      f.write mail.to_s
    end

    Rails.logger.autoresponder.error """
      AutoResponder: Error with email. No response email sent.
        Messag-Id: #{mail.message_id.parameterize}
        From: #{mail.from.join ', '}
        Subject: #{mail.subject}
        Exception: #{e.to_s}
    """

    binding.pry
  end
end
