require "csv"

class Import::StudentImport < ActiveRecord::Base
  IMPORTABLE_ATTRIBUTES = [:tutorial_group, :email, :forename, :surname, :matriculum_number, :registered_at, :comment].freeze
  STATES = ["pending", "imported"].freeze

  # associations
  belongs_to :term

  # attributes
  attr_accessible :term_id, :file, :file_cache, :import_options, :import_mapping
  mount_uploader :file, Import::StudentImportsUploader
  serialize :import_options, Hash
  serialize :import_mapping, Import::ImportMapping

  # callbacks
  before_validation :fill_status, on: :create

  #validations
  validates_presence_of :file, :term_id
  validates_inclusion_of :status, in: STATES

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
    begin
      students = []
      student_registrations = []

      values.each do |row|
        email = row[import_mapping.email.to_i]

        student = Account.find_or_initialize_by_email(email)
        student.forename = row[import_mapping.forename.to_i]
        student.surname = row[import_mapping.surname.to_i]
        student.email = email
        student.matriculum_number = row[import_mapping.matriculum_number.to_i]
        student.password = "123456" # TODO change default password
        student.password_confirmation = "123456"
        students << student

        group_title = row[import_mapping.tutorial_group.to_i]
        tutorial_group = term.tutorial_groups.find_or_initialize_by_title(group_title)
        tutorial_group.save!

        registration = tutorial_group.student_registrations.find_or_initialize_by_account_id(student.id)
        registration.registered_at = row[import_mapping.registered_at.to_i].to_datetime
        registration.comment = row[import_mapping.comment.to_i] if import_mapping.comment
        student_registrations << registration
      end

      Account.uncached do
        Account.transaction do
          students.each do |account|
            account.save!
          end
        end
      end

      StudentRegistration.uncached do
        StudentRegistration.transaction do
          student_registrations.each do |registration|
            registration.save!
          end
        end
      end

      self.status = "imported"
      self.save

    rescue
      puts $!
      false
    end
  end

  def parsed?
    !!@parsed_file
  end

  def parsing_error?
    @parsing_error
  end

  def headers
    @headers if values
  end

  def values
    @parsed_file ||= parsed_csv_file
  end

  def smart_guess_new_import_mapping
    smart_guessed_import_mapping = Import::ImportMapping.new

    # guess mapping from content
    if values.any?
      row = values.first

      row.each_index do |cell_index|
        smart_guessed_import_mapping.tutorial_group = cell_index if /\AT[\d]{1}/ =~ row[cell_index]
        smart_guessed_import_mapping.email = cell_index if /.*?@?.*/ =~ row[cell_index]
        smart_guessed_import_mapping.matriculum_number = cell_index if /\A[\d]{7}\z/ =~ row[cell_index]

        begin
          smart_guessed_import_mapping.registered_at = cell_index if row[cell_index].to_datetime
        rescue
        end
      end
    end

    # hard coded values of headers
    headers.each_index do |cell_index|
      smart_guessed_import_mapping.forename = cell_index if /.*Vorname.*/ =~ headers[cell_index]
      smart_guessed_import_mapping.surname = cell_index if /.*Nachname.*/ =~ headers[cell_index]
      smart_guessed_import_mapping.comment = cell_index if /.*Anmerkung.*/ =~ headers[cell_index]
    end if headers


    self.import_mapping = smart_guessed_import_mapping
    self.save
  end





  private

  def parsed_csv_file
    options = {}
    options[:col_sep] = import_options[:col_seperator] || ";"
    options[:quote_char] = import_options[:quote_char] || "\""

    @headers = []
    records = []
    text = File.open(self.file.to_s, "r").read
    text = text.force_encoding("UTF-8").gsub("\xEF\xBB\xBF".force_encoding("UTF-8"), '')
    text.split(/\n/).each_with_index do |line, index|
      line.strip!
      begin
        values = CSV.parse_line(line, options).keep_if {|cell| cell.present?}

        if index == 0 && import_options[:headers_on_first_line] == "1"
          @headers = values
        else
          records << values
        end
      rescue CSV::MalformedCSVError => e
        @parsing_error = true
        records << ["Couldn't parse this line: #{line}", e.inspect]
      end
    end
    records
  end

  def fill_status
    self.status = "pending"
  end
end
