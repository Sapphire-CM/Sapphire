require 'csv'

class ImportService
  include Import::Parser
  include Import::Importer

  attr_reader :import, :import_options, :import_mapping, :import_result

  def initialize(import)
    @import = import
    @import_options = import.import_options
    @import_mapping = import.import_mapping
    @import_result = import.import_result
  end

  def perform!
    import.running!
    import_result.reset!

    begin
      import!
    rescue => e
      import.failed!
      raise e
    end
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

  def encoding_error?
    parse_csv unless @parsed
    import_result.encoding_error?
  end

  def parsing_error?
    parse_csv unless @parsed
    import_result.parsing_error?
  end
end
