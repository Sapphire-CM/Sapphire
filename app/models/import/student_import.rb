require "csv"

class Import::StudentImport < ActiveRecord::Base
  include Import::Parser
  include Import::Importer

  IMPORTABLE_ATTRIBUTES = [:group, :email, :forename, :surname, :matriculum_number, :registered_at, :comment].freeze
  STATES = ["pending", "imported"].freeze

  # associations
  belongs_to :term

  # attributes
  attr_accessible :term_id, :file, :file_cache, :import_options, :import_mapping, :import_result

  mount_uploader :file, Import::StudentImportsUploader
  serialize :import_options, Hash
  serialize :import_mapping, Import::ImportMapping
  serialize :import_result, Hash

  # validations
  validates_presence_of :file, :term_id
  validates_inclusion_of :status, in: STATES

  def initialize(*args)
    super *args

    @parsed = false
    @encoding_error = false
    @parsing_error = false

    import_options[:matching_groups]        ||= "first"
    import_options[:tutorial_groups_regexp] ||= '\AT(?<tutorial>[\d]+)\z'
    import_options[:student_groups_regexp]  ||= '\AG(?<tutorial>[\d]+)-(?<student>[\d]+)\z'

    import_options[:headers_on_first_line]  ||= "1"
    import_options[:column_separator]       ||= ";"
    import_options[:quote_char]             ||= "\""
    import_options[:decimal_separator]      ||= ","
    import_options[:thousands_separator]    ||= "."

    self.status ||= "pending"
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

  def parsed?
    !!@parsed_file
  end

  def encoding_error?
    @encoding_error
  end

  def parsing_error?
    @parsing_error
  end

  def headers
    parse_csv unless @headers
    @headers
  end

  def values
    parse_csv unless @values
    @values
  end

  def column_count
    if headers && headers.length > 0
      headers.length
    elsif values && values.length > 0
      values.first.length
    else
      0
    end
  end

end
