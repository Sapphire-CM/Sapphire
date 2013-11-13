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

    charset 'UTF-8'
    content_type 'text/plain; charset=UTF-8'
    transport_encoding '8bit'

    body args[:body]
  end
end

def new_mails
  mails = Mail.all delete_after_find: true
  mails.each do |mail|
    filename = "#{mail.date.to_s.parameterize}-#{mail.message_id.parameterize}.eml"
    filename = File.join('emails', filename)
    File.open(filename, 'w') do |f|
      f.write(mail.to_s)
    end
  end
  mails
end

def process_email(mail)
  begin
    execute mail
  rescue
    message = "AutoResponder: Error with email. No response email sent.\n"
    message << "  Messag-Id: #{mail.message_id.parameterize}\n"
    message << "  From: #{mail.from.join ', '}\n"
    message << "  Subject: #{mail.subject}\n"

    Rails.logger.error message
  end
end
