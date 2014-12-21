class SubmissionExport < Export
  prop_accessor :base_path, :solitary_path, :group_path, :extract_zips, :include_solitary_submissions, :include_group_submissions

  validates :base_path, presence: true
  validates :solitary_path, presence: true, if: :include_solitary_submissions?
  validates :group_path, presence: true, if: :include_group_submissions?

  include ZipGeneration

  def perform!
    raise ExportError unless persisted?

    Dir.mktmpdir do |dir|
      prepare_zip!(dir)
      generate_zip_and_assign_to_file!(dir)
    end
  end

  def prepare_zip!(directory)
    term.submissions.find_each do |submission|
      submission.submission_assets.each do |submission_asset|
        if should_add?(submission_asset) && File.exist?(submission_asset.file.to_s)
          add_asset_to_zip(submission_asset, directory)
        end
      end
    end
  end

  def include_solitary_submissions?
    self.include_solitary_submissions == "1"
  end

  def include_group_submissions?
    self.include_group_submissions == "1"
  end

  def extract_zips?
    self.extract_zips == "1"
  end

  private
  def should_add?(submission_asset)
    exercise = submission_asset.submission.exercise
    exercise.group_submission? && include_group_submissions? || exercise.solitary_submission? && include_solitary_submissions?
  end

  def add_asset_to_zip(submission_asset, zip_tmp_dir)
    path = File.join(zip_tmp_dir, submission_asset_path(submission_asset))

    if extract_zips? && submission_asset.content_type == SubmissionAsset::Mime::ZIP
      extraction_dir = File.dirname(path)
      extract_zip_to(submission_asset.file.to_s, extraction_dir)
    else
      hardlink_file(submission_asset.file.to_s, path)
    end
  end

  def extract_zip_to(zip_path, extraction_dir)
    Zip::File.open(zip_path) do |archive|
      archive.entries.each do |entry|
        # ignoring directories - as mkdir_p is more reliable
        next if entry.name[-1] == "/"

        extraction_path = File.join(extraction_dir, entry.name)
        FileUtils.mkdir_p(File.dirname(extraction_path))
        entry.extract(extraction_path)
      end
    end
  rescue => e
    puts "zip #{zip_path} could not be extracted, hardlinking original file"

    FileUtils.rm_r(extraction_dir)
    hardlink_file(zip_path, File.join(extraction_dir, File.basename(zip_path)))
  end

  def hardlink_file(source_path, dst_path)
    FileUtils.mkdir_p(File.dirname(dst_path))
    File.link(source_path, dst_path)
  end

  def submission_asset_path(submission_asset)
    filename = File.basename submission_asset.file.to_s

    inferred_zip_path(submission_asset, filename, submission_asset.submission.exercise.group_submission?)
  end

  def inferred_zip_path(submission_asset, filename, use_group_path)
    paths = []
    paths << inferred_path(self.base_path, submission_asset)

    if use_group_path
      paths << inferred_path(self.group_path, submission_asset)
    else
      paths << inferred_path(self.solitary_path, submission_asset)
    end

    paths << filename

    File.join(*paths)
  end

  def inferred_path(path, submission_asset)
    placeholders = extract_placeholders(path)

    filled_placeholders = placeholders.map {|placeholder| [placeholder.to_sym, value_for_placeholder(placeholder, submission_asset)]}

    path % Hash[filled_placeholders]
  end

  def extract_placeholders(path)
    path.scan(/%\{([^\}]+)\}/).lazy.map(&:first).map(&:to_s).to_a
  end

  def value_for_placeholder(placeholder, submission_asset)
    value = case placeholder
    when "student_group" then submission_asset.submission.student_group.try(:title)
    when "exercise" then submission_asset.submission.exercise.try(:title)
    when "av_grade" then average_grade_for(submission_asset.submission.term_registrations).to_s
    when "course" then term.course.title
    when "term" then term.title
    when "matriculation_number" then matriculation_numbers_for(submission_asset.submission.term_registrations)
    end

    value.present? ? value.parameterize : nil
  end

  def average_grade_for(term_registrations)
    if term_registrations.any?
      grades = term_registrations.map {|tr| grading_scale.grade_for_term_registration(tr) }
      average = grades.reduce(:+).to_f / grades.length

      average.round.to_s
    else
      "x"
    end
  end

  def matriculation_numbers_for(term_registrations)
    term_registrations.map { |tr| tr.account.matriculation_number }.join(" ")
  end

  def grading_scale
    @grading_scale ||= GradingScaleService.new(term)
  end
end
