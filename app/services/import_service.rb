require 'csv'

class ImportService
  include Import::FileParser
  include Import::Importer

  attr_accessor :import, :import_options, :import_mapping, :import_result

  def initialize(import)
    @import = import
    @import_options = import.import_options
    @import_mapping = import.import_mapping
    @import_result = import.import_result
  end

  def perform!
    @import.update! status: :running
    @import_result.reset!

    begin
      import!
    rescue => e
      import.failed!
      raise e
    end

    @import.update! status: :finished
  end

  def headers
    parse_import_file unless @parsed
    @headers
  end

  def values
    parse_import_file unless @parsed
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

  def encoding_error?
    parse_import_file unless @parsed
    @import_result.encoding_error?
  end

  def parsing_error?
    parse_import_file unless @parsed
    @import_result.parsing_error?
  end
end
