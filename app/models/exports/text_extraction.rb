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
	prop_accessor :exercise, :group_path

	validates :exercise, presence: true

	include ZipGeneration

	def set_default_values!
		self.exercise ||= "%{exercise}"		
		self.group_path ||= "groups/%{student_group}"
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
			tmp_dir << student_group.tutorial_group.title
			tmp_dir << student_group.title
			submission.submission_assets.each do |asset|
				if should_add?(asset)
					add_asset_to_zip(asset, tmp_dir)			
				end
			end
		end
	end

	private

	def should_add?(submission_asset)
		submission_asset.content_type == "text/html"
	end

  def add_asset_to_zip(submission_asset, zip_tmp_dir)
    filename = File.basename submission_asset.file.to_s
    path = File.join(zip_tmp_dir, File.join(filename))

    hardlink_file(submission_asset.file.to_s, path)
  end

  def extract_section(submission_asset, selector)
  	text = Nokogiri::HTML(submission_asset.file.read)
  	section = text.css(selector)
  	unless section.present?
  		export_section_path += ".no-id"
  	end	
  end

  def hardlink_file(source_path, dst_path)
    FileUtils.mkdir_p(File.dirname(dst_path))
    File.link(source_path, dst_path)
  end


end
