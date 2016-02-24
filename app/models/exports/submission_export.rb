# create_table :exports, force: :cascade do |t|
#   t.string   :type
#   t.integer  :status
#   t.integer  :term_id
#   t.string   :file
#   t.text     :properties
#   t.datetime :created_at, null: false
#   t.datetime :updated_at, null: false
# end
#
# add_index :exports, [:term_id], name: :index_exports_on_term_id

require 'zip'

class Exports::SubmissionExport < Export
  prop_accessor :base_path, :solitary_path, :group_path, :extract_zips, :include_solitary_submissions, :include_group_submissions

  validates :base_path, presence: true
  validates :solitary_path, presence: true, if: :include_solitary_submissions?
  validates :group_path, presence: true, if: :include_group_submissions?

  include ZipGeneration

  after_initialize :set_default_values

  def perform!
    fail ExportError unless persisted?

    Dir.mktmpdir do |dir|
      prepare_zip!(dir)
      generate_zip_and_assign_to_file!(dir)
    end
  end

  def prepare_zip!(directory)
    SubmissionAsset.for_term(term).includes(submission: :exercise).find_each do |submission_asset|
      if should_add?(submission_asset) && File.exist?(submission_asset.file.to_s)
        add_asset_to_zip(submission_asset, directory)
      end
    end
  end

  def include_solitary_submissions?
    include_solitary_submissions == '1'
  end

  def include_group_submissions?
    include_group_submissions == '1'
  end

  def extract_zips?
    extract_zips == '1'
  end

  private

  def set_default_values
    self.base_path ||= "%{course}-%{term}"
    self.solitary_path ||= "solitary/%{matriculation_number}/%{exercise}"
    self.group_path ||= "groups/%{student_group}-%{av_grade}/%{exercise}"
    self.extract_zips = true if self.extract_zips.nil?
    self.include_solitary_submissions = true if self.include_solitary_submissions.nil?
    self.include_group_submissions = true if self.include_group_submissions.nil?
  end


  def should_add?(submission_asset)
    exercise = submission_asset.submission.exercise
    exercise.group_submission? && include_group_submissions? || exercise.solitary_submission? && include_solitary_submissions?
  end

  def add_asset_to_zip(submission_asset, zip_tmp_dir)
    path = File.join(zip_tmp_dir, submission_asset_path(submission_asset))

    if extract_zips? && submission_asset.content_type == SubmissionAsset::Mime::ZIP
      extraction_dir = path_without_extension(path)

      begin
        extract_zip_to(submission_asset.file.to_s, unique_path(extraction_dir))
      rescue => e
        # zip could not be extracted, falling back to hardlinking original file instead

        FileUtils.rm_r(extraction_dir) if File.exist?(extraction_dir)
        hardlink_file(submission_asset.file.to_s, unique_path(path))
      end
    else
      hardlink_file(submission_asset.file.to_s, unique_path(path))
    end
  end

  def extract_zip_to(zip_path, extraction_dir)
    zip_name = File.basename(zip_path, File.extname(zip_path))
    Zip::File.open(zip_path) do |archive|
      archive.entries.each do |entry|
        # ignoring directories - as mkdir_p is more reliable
        next if entry.name[-1] == '/'

        # do not include zip file name twice
        entry_name = entry.name
        if entry_name.start_with?(zip_name)
          entry_name = entry_name[zip_name.length..-1]
        elsif entry_name.start_with?("/#{zip_name}")
          entry_name = entry_name[(zip_name.length + 1)..-1]
        end

        extraction_path = File.join(extraction_dir, entry_name)
        FileUtils.mkdir_p(File.dirname(extraction_path))
        entry.extract(extraction_path)
      end
    end
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
    paths << inferred_path(base_path, submission_asset)

    if use_group_path
      paths << inferred_path(group_path, submission_asset)
    else
      paths << inferred_path(solitary_path, submission_asset)
    end

    paths << filename

    File.join(*paths)
  end

  def inferred_path(path, submission_asset)
    placeholders = extract_placeholders(path)

    filled_placeholders = placeholders.map { |placeholder| [placeholder.to_sym, value_for_placeholder(placeholder, submission_asset)] }

    path % Hash[filled_placeholders]
  end

  def unique_path(path)
    return path unless File.exist? path

    basepath = path_without_extension(path)
    extname = File.extname(path)

    i = 2
    loop do
      unique_path = "#{basepath}-#{i}#{extname}"
      return unique_path unless File.exist?(unique_path)

      i += 1
    end
  end

  def path_without_extension(path)
    ext = File.extname(path)

    path[0..(-ext.length - 1)]
  end

  def extract_placeholders(path)
    path.scan(/%\{([^\}]+)\}/).lazy.map(&:first).map(&:to_s).to_a
  end

  def value_for_placeholder(placeholder, submission_asset)
    value = case placeholder
    when 'student_group'
      submission_asset.submission.student_group.try(:title)
    when 'exercise'
      submission_asset.submission.exercise.try(:title)
    when 'av_grade'
      average_grade_for(submission_asset.submission).to_s
    when 'course'
      term.course.title
    when 'term'
      term.title
    when 'matriculation_number'
      matriculation_numbers_for(submission_asset.submission.term_registrations)
    when 'tutorial_group'
      tutorial_group_title_for(tutorial_group_for(submission_asset))
    end

    value.present? ? value.parameterize : nil
  end

  def average_grade_for(submission)
    grading_scale_service = GradingScaleService.new(term)

    if submission.student_group.present?
      grading_scale_service.average_grade_for_student_group(submission.student_group).round
    elsif submission.term_registrations.any?
      grading_scale_service.average_grade_for_term_registrations(submission.term_registrations).round
    else
      'x'
    end
  end

  def matriculation_numbers_for(term_registrations)
    term_registrations.map { |tr| tr.account.matriculation_number }.join(' ')
  end

  def tutorial_group_for(submission_asset)
    submission = submission_asset.submission

    if submission.student_group.present?
      submission.student_group.tutorial_group
    else
      submission.tutorial_groups.first
    end
  end

  def tutorial_group_title_for(tutorial_group)
    if tutorial_group.present?
      parts = []
      parts << tutorial_group.title
      parts += tutorial_group.tutor_accounts.map(&:forename)
      parts.join("-").downcase
    else
      "no-tutorial-group"
    end
  end
end
