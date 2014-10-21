require 'tempfile'

class NewsgroupFetcherService < Service
  prop_accessor :server_url, :newsgroups, :fetch_initial, :fetch_followups

  def title
    "Newsgroup Fetcher"
  end

  def fetch_initial?
    fetch_initial == "1"
  end

  def fetch_followups?
    fetch_followups == "1"
  end

  def perform!
    raise InvalidStateException.new("cannot import non-solitary newsgroup posts") unless exercise.solitary_submission?

    @client = NNTP::Client::Session.new(self.server_url)

    fetchable_newsgroups.each do |ng|
      import_submissions_for ng
    end
  ensure
    @client.finish!
  end

  private
  def fetchable_newsgroups
    requested_ngs = self.newsgroups.split

    @client.newsgroups.select {|ng| requested_ngs.include? ng.title }
  end

  def import_submissions_for(newsgroup)
    newsgroup.posts.each do |post|
      parsed_post = Mail.new post.raw

      if should_import? parsed_post
        import_post post.raw, parsed_post
      end
    end
  end

  def should_import?(post)
    (fetch_initial? && post.header["References"].blank?) || (fetch_followups? && post.header["References"].present?)
  end

  def import_post(raw_post, parsed_post)
    submission_asset = SubmissionAsset.for_exercise(exercise).find_by_import_identifier(parsed_post.message_id)

    if submission_asset.present?
      submission = submission_asset.submission

      if submission.submitter.blank?
        if submitter_registration = submitter_for_post(parsed_post)
          add_submitter_for_submission(submission, submitter_registration, parsed_post)
          submission.save!
        end
      end
    else
      submitter_registration = submitter_for_post(parsed_post)

      if submitter_registration.present?
        # ignore staff posts
        unless submitter_registration.staff?
          import_submission_for_submitter!(submitter_registration, raw_post, parsed_post)
        end
      else
        # unkown submitter
        create_unkown_submission!(raw_post, parsed_post)
      end
    end
  rescue => e
    Rails.logger.info "Could not import newsgroup post #{parsed_post.message_id}"
    Rails.logger.info e.inspect
    Rails.logger.info e.backtrace.join("\n")
  end

  def create_unkown_submission!(raw_post, parsed_post)
    submission = Submission.create!(exercise: exercise, submitted_at: parsed_post.date || Time.now)

    submission_asset = SubmissionAsset.new
    setup_submission_asset(submission_asset, raw_post, parsed_post)
    submission_asset.submission = submission
    submission_asset.save!
  end

  def import_submission_for_submitter!(submitter_registration, raw_post, parsed_post)
    exercise_registration = submitter_registration.exercise_registrations.for_exercise(exercise).first

    date = parsed_post.date || Time.now

    if exercise_registration.present?
      submission = exercise_registration.submission
      submission.submitted_at = date
      submission.save!
    else
      submission = Submission.create!(exercise: exercise, submitted_at: date)
      add_submitter_for_submission(submission, submitter_registration, parsed_post)
      submission.save!
    end

    submission_asset = SubmissionAsset.new
    setup_submission_asset(submission_asset, raw_post, parsed_post)
    submission_asset.submission = submission
    submission_asset.save!
  end

  def setup_submission_asset(submission_asset, raw_post, parsed_post)
    submission_asset.file = write_submission_file(raw_post)
    submission_asset.content_type = SubmissionAsset::Mime::NEWSGROUP_POST
    submission_asset.import_identifier = parsed_post.message_id
  end

  def add_submitter_for_submission(submission, submitter_registration, parsed_post)
    submission.submitter = submitter_registration.account
    ExerciseRegistration.create!(exercise: exercise, term_registration: TermRegistration.find(submitter_registration.id), submission: submission)
  end

  def write_submission_file(raw_post)
    tmp_file = Tempfile.new("sapphire-submission")
    tmp_file.write raw_post.force_encoding("UTF-8")
    tmp_file
  end


  def submitter_for_post(parsed_post)
    emails = []
    emails += parsed_post.from
    emails += parsed_post.reply_to if parsed_post.reply_to.present?

    possible_submitters = exercise.term.term_registrations.for_email_addresses(emails).load

    if possible_submitters.size == 1
      possible_submitters.first
    else
      nil
    end
  end
end