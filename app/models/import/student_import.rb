require "csv"

class Import::StudentImport < ActiveRecord::Base
  extend Enum
  include Import::Parser
  include Import::Importer

  IMPORTABLE_ATTRIBUTES = [:group, :email, :forename, :surname, :matriculation_number, :comment].freeze

  belongs_to :term

  mount_uploader :file, Import::StudentImportsUploader

  serialize :import_options, Hash
  serialize :import_mapping, Import::ImportMapping
  serialize :import_result, Hash

  enum status: [:pending, :running, :finished, :failed]

  validates :term, presence: true
  # validates :file, presence: true

  def initialize(*args)
    super *args

    @parsed = false
    @encoding_error = false
    @parsing_error = false

    self.status = :pending

    import_options[:matching_groups]        ||= "first"
    import_options[:tutorial_groups_regexp] ||= '\AT(?<tutorial>[\d]+)\z'
    import_options[:student_groups_regexp]  ||= '\AG(?<tutorial>[\d]+)-(?<student>[\d]+)\z'

    import_options[:headers_on_first_line]  ||= "1"
    import_options[:column_separator]       ||= ";"
    import_options[:quote_char]             ||= "\""
    import_options[:decimal_separator]      ||= ","
    import_options[:thousands_separator]    ||= "."
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
