module Import::Parser
  def parse_csv
    csv_options = {
      col_sep: import_options.column_separator,
      quote_char: import_options.quote_char,
    }

    # not used: import_options.decimal_separator
    # not used: import_options.thousands_separator

    @headers = []
    @values = []

    load_csv_text.each_with_index do |line, index|
      values = parse_csv_line(line, csv_options)

      if index == 0 && import_options.headers_on_first_line
        @headers = values
      else
        @values << values
      end
    end

    true
  end

  private

  def load_csv_text
    text = File.open(import.file.to_s, 'r').read
    text = text.force_encoding('UTF-8').gsub("\xEF\xBB\xBF".force_encoding('UTF-8'), '')
    text.split(/\n/)
  rescue Exception => e
    import_result.update! encoding_error: true
    text = []   end

  def parse_csv_line(line, csv_options)
    begin
      values = CSV.parse_line(line.strip, csv_options).keep_if(&:present?)
    rescue CSV::MalformedCSVError => e
      import_result.update! parsing_error: true
      values = [line]
    end

    values
  end
end
