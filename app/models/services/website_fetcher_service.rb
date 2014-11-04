class WebsiteFetcherService < Service
  prop_accessor :subdirectory

  class Webspace
    attr_accessor :account
    def initialize(account)
      @account = account
    end

    def identifier
      account.email.gsub(/@.*$/, "")
    end

    def submission_file_links
      Rails.logger.info "retrieving filelist for #{identifier}"

      url = "http://www.student.tugraz.at/cgi-bin/filelist.csh?#{identifier}"

      agent = Mechanize.new
      file_list_page = agent.get(url)

      page_links = file_list_page.links.select { |l| l.href !~ /\/$/}

      regex = /#{identifier}\/inm\//

      matching_links = page_links.select {|l| l.href =~ regex }

      if matching_links.any?
        matching_links
      else
        page_links
      end
    end
  end


  def title
    "Website Fetcher"
  end

  def perform!
    exercise.term.term_registrations.students.each do |term_registration|
      WebsiteFetcherWorker.perform_async(self.id, term_registration.id)
    end
  end

  def fetch_for_term_registration(term_registration)
    account = term_registration.account

    webspace = Webspace.new(account)
    links = webspace.submission_file_links

    if links.any?
      Dir.mktmpdir do |dir|
        submission = submission_for_term_registration(term_registration)

        links.each do |link|
          import_id = link.href
          unless submission.submission_assets.where(import_identifier: import_id).exists?
            download = link.click

            submission_asset = SubmissionAsset.new(import_identifier: import_id, content_type: content_type_for_download(download))

            path = File.join(dir, link.href)
            FileUtils.mkdir_p(File.dirname(path))

            download.save!(path)

            submission_asset.file = File.open(path)
            submission.submission_assets << submission_asset
          end
        end
      end
    end
  end

  private

  def submission_for_term_registration(term_registration)
    if (exercise_registrations = term_registration.exercise_registrations.where(exercise_id: exercise.id)).exists?
      exercise_registrations.first.submission
    else
      submission = Submission.new(submitted_at: Time.now, submitter: term_registration.account, exercise: exercise)
      submission.save!
      submission.exercise_registrations << ExerciseRegistration.new(exercise: exercise, term_registration: term_registration, submission: submission)
      submission
    end
  end

  def content_type_for_download(download)
    case download.response["content-type"]
    when "application/xhtml+xml"
      SubmissionAsset::Mime::HTML
    else
      download.response["content-type"]
    end
  end
end
