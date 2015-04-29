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
    message.deliver_later

    File.open("emails/response/#{mail_filename message}", 'w') do |f|
      f.write(message.to_s)
    end
  end
end

def new_mails(exercise)
  emails =  Mail.all delete_after_find: true

  emails.each do |email|
    import_email email, exercise
  end
end

def import_email(email, exercise)
  submission_asset = SubmissionAsset.for_exercise(exercise).find_by_import_identifier(email.message_id)
  return if submission_asset.blank?

  submitter_registration = submitter_for_email(email, exercise)

  if submitter_registration.present?
    import_submission_for_submitter!(exercise, submitter_registration, email.to_s, email)
  else
    # unkown submitter
    create_unkown_submission!(exercise, email.to_s, email)
  end
end

def import_submission_for_submitter!(exercise, submitter_registration, raw_post, parsed_post)
  exercise_registration = submitter_registration.exercise_registrations.for_exercise(exercise).first

  date = parsed_post.date || Time.now

  if exercise_registration.present?
    submission = exercise_registration.submission
    submission.submitted_at = date
    submission.save!
  else
    submission = Submission.create!(exercise: exercise, submitted_at: date)
    add_submitter_for_submission(exercise, submission, submitter_registration)
    submission.save!
  end

  submission_asset = SubmissionAsset.new
  setup_submission_asset(submission_asset, raw_post, parsed_post)
  submission_asset.submission = submission
  submission_asset.save!
end

def submitter_for_email(parsed_email, exercise)
  emails = []
  emails += parsed_email.from
  emails += parsed_email.reply_to if parsed_email.reply_to.present?

  possible_submitters = exercise.term.term_registrations.for_email_addresses(emails).load

  if possible_submitters.size == 1
    possible_submitters.first
  end
end

def setup_submission_asset(submission_asset, raw_post, parsed_post)
  submission_asset.file = write_submission_file(raw_post)
  submission_asset.content_type = SubmissionAsset::Mime::EMAIL
  submission_asset.import_identifier = parsed_post.message_id
end

def write_submission_file(raw_post)
  tmp_file = Tempfile.new('sapphire-submission')
  tmp_file.write raw_post.force_encoding('UTF-8')
  tmp_file
end

def add_submitter_for_submission(exercise, submission, submitter_registration)
  submission.submitter = submitter_registration.account
  ExerciseRegistration.create!(exercise: exercise, term_registration: TermRegistration.find(submitter_registration.id), submission: submission)
end

def create_unkown_submission!(exercise, raw_post, parsed_post)
  submission = Submission.create!(exercise: exercise, submitted_at: parsed_post.date || Time.now)

  submission_asset = SubmissionAsset.new
  setup_submission_asset(submission_asset, raw_post, parsed_post)
  submission_asset.submission = submission
  submission_asset.save!
end

def process_email(mail, exercise)
  execute mail, exercise
rescue Exception => e
  File.open("emails/failure/#{mail_filename mail}", 'w') do |f|
    f.write mail.to_s
  end

  Rails.logger.autoresponder.error ''"
    AutoResponder: Error with email. No response email sent.
      Message-Id: #{mail.message_id.parameterize}
      From: #{mail.from.join ', '}
      Subject: #{mail.subject}
      Exception: #{e}
  "''
  Rails.logger.error e.backtrace.join("\n")
end
