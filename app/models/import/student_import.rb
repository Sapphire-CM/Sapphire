require "csv"

class Import::StudentImport < ActiveRecord::Base
  IMPORTABLE_ATTRIBUTES = [:tutorial_group, :email, :forename, :surname, :matriculum_number, :registered_at].freeze
  STATES = ["pending", "imported"].freeze
  FORMATS = ["csv"].freeze
  
  # associations
  belongs_to :term
    
  # attributes
  attr_accessible :format, :term_id, :file, :file_cache, :import_options, :import_mapping
  mount_uploader :file, Import::StudentImportsUploader
  serialize :import_options, Hash
  serialize :import_mapping, Import::ImportMapping
  
  # callbacks
  before_validation :determine_format, :if => lambda {|student_import| student_import.format.blank? && student_import.file.identifier.present? }
  before_validation :fill_status, :on => :create
  
  #validations
  validates_presence_of :file, :term_id
  validates_inclusion_of :status, :in => STATES
  # validates_inclusion_of :format, :in => FORMATS
  
  #scopes
  scope :for_course, lambda {|course| joins(:term).where {term.course_id == course} }
  scope :for_term, lambda {|term| where {term_id == term} }
  scope :with_terms, joins(:term).includes(:term)
  
  def initialize(*args)
    super *args
    @parsed = false
    @parsing_error = false
  end
  
  def import_mapping
    if read_attribute(:import_mapping).nil?
      write_attribute :import_mapping, Import::ImportMapping.new
      read_attribute :import_mapping
    else
      read_attribute :import_mapping
    end
  end

  def import_mapping=(val)
    val = Import::ImportMapping.new(val) unless val.class == Import::ImportMapping
    
    write_attribute :import_mapping, val
  end
  
  
  def pending?
    self.status == "pending"
  end
  
  def imported?
    self.status == "imported"
  end
  
  
  def import!
    values = parsed_file
    
    begin
      values.each do |row|
        email = row[import_mapping.email.to_i]
        matriculum_number = row[import_mapping.matriculum_number.to_i]
        student = Account.find_or_initialize_by_email(email)
        student.forename = row[import_mapping.forename.to_i]
        student.surname = row[import_mapping.surname.to_i]
        student.email = email
        student.matriculum_number = row[import_mapping.matriculum_number.to_i]
        student.password = "123456" # TODO change default password
        student.password_confirmation = "123456"
        student.save!
        
        group_title = row[import_mapping.tutorial_group.to_i]
        tutorial_group = term.tutorial_groups.find_or_initialize_by_title(group_title)
        tutorial_group.save!
              
        registration = tutorial_group.student_term_registrations.find_or_initialize_by_account_id(student.id)
        registration.registered_at = DateTime.parse(row[import_mapping.registered_at.to_i].gsub(/,/, " "))
        # registration = student.term_registrations.where(:term_id => term).first || student.term_registrations.new
        # registration.term = term
        # registration.tutorial_group = tutorial_group
        registration.save!
      end
      self.status = "imported"
      self.save

    # rescue
    #   false
    end
  end
  
  def parsed?
    !!@parsed_file
  end
  
  def parsing_error?
    @parsing_error
  end
  
  def parsed_file
    @parsed_file ||= case self.format
    when "csv" then parsed_csv_file
    when "xml" then parsed_xml_file
    end
  end
  
  
  
  private
  
  def parsed_csv_file
    options = {}
    options[:col_sep] = import_options[:col_seperator] || ";"
    options[:quote_char] = import_options[:quote_char] || "\""

    records = []
    text = File.open(self.file.to_s, "r").read
    text = text.force_encoding("UTF-8").gsub("\xEF\xBB\xBF".force_encoding("UTF-8"), '')
    text.split(/\n/).each_with_index do |line, index|
      # ignore first line
      next if index == 0 && import_options[:headers_on_first_line] == "1"

      line.strip!
      begin
        records << CSV.parse_line(line, options).keep_if {|cell| cell.present?}
      rescue CSV::MalformedCSVError => e
        @parsing_error = true
        records << ["Couldn't parse this line: #{line}", e.inspect]
      end
    end
    records
  end
  
  def parsed_xml_file
    
  end
  
  
  def fill_status
    self.status = "pending"
  end
  
  def determine_format
    ext = File.extname self.file.identifier
    
    self.format = case ext
    when ".csv"
      "csv"
    when ".xml"
      "xml"
    else
      FORMATS.first
    end
    
  end
end
