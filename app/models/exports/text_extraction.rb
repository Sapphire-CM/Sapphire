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
require 'nokogiri'

class Exports::TextExtraction < Export
	prop_accessor :exercise, :group_path, :selector

	validates :exercise, presence: true
  validates :selector, presence: true 

	include ZipGeneration

	def set_default_values!
    self.exercise ||= "%{exercise}"		
    self.group_path ||= "groups/%{student_group}"
    self.selector ||= "section#secEvaluationMethodology"
  end 

	def perform!
		fail ExportError unless persisted?
		
	  Dir.mktmpdir do |dir|
	   prepare_zip!(dir)
	   generate_zip_and_assign_to_file!(dir)
	  end
	end

  def prepare_zip!(dir)
    exercise = Exercise.find(self.exercise)
    submissions = exercise.submissions.to_a
    submissions.each do |submission|
      student_group = submission.student_group
      tmp_dir = []
      tmp_dir << dir
      tutorial_group_dir = student_group.tutorial_group.title + "-"
      tutorial_group_dir += "ex" + self.exercise
      tmp_dir << tutorial_group_dir
      submission.submission_assets.where(content_type: SubmissionAsset::Mime::HTML).each do |asset|
        if should_add?(asset, exercise.title)
          add_file_to_zip(student_group.title, asset.file.to_s, tmp_dir, "html")
          section = extract_section(asset, self.selector)
          add_file_to_zip(student_group.title, section, tmp_dir, "text")
        end
      end
    end
  end

	private

  def should_add?(submission_asset, exercise)
    bool = false
    if exercise.include?("HE")
      bool = submission_asset.filename.include?("he")
    elsif exercise.include?("TA")
      bool = submission_asset.filename.include?("ta")
    end
    bool
  end 

	def add_file_to_zip(student_group, file_path, zip_tmp_dir, type)
  	filename = student_group + "-" + File.basename(file_path)
  	parent_directory = zip_tmp_dir.last + "-" + type
    path = File.join(zip_tmp_dir[0..-2], parent_directory, File.join(filename))
    hardlink_file(file_path, path)
  end 

   def extract_section(submission_asset, selector)
  	export_section_path = File.join(submission_asset.file.to_s + "#" + selector + ".txt")
  	FileUtils.cp(submission_asset.file.to_s, export_section_path)
  	html = Nokogiri::HTML(submission_asset.file.read)
  	section = html.css(selector)
  	unless section.present?
  		export_section_path += ".no-id"
  	end
  	text = (section.presence || html).inner_text
  	
  	File.open(export_section_path, "w") do |export_text|
  		export_text.puts text
  		word_count = text.split.size
  		export_text.puts "Word count: " + word_count.to_s
  	end
  	export_section_path	
  end

  def hardlink_file(source_path, dst_path)
    FileUtils.mkdir_p(File.dirname(dst_path))
    File.link(source_path, dst_path)
  end


end
