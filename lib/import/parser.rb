module Import::Parser
  def parse_csv
    csv_options = {}
    csv_options[:col_sep] = import_options.column_separator || ";"
    csv_options[:quote_char] = import_options.quote_char || "\""

    # not used: import_options.decimal_separator || ","
    # not used: import_options.thousands_separator || "."

    @headers = []
    @values = []

    text = load_csv_text

    text.split(/\n/).each_with_index do |line, index|
      line.strip!

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
    begin
      text = File.open(self.file.to_s, "r").read
      text = text.force_encoding("UTF-8").gsub("\xEF\xBB\xBF".force_encoding("UTF-8"), '')
    rescue Exception => e
      @encoding_error = true
      text = "" # empty string should not harm anybody else
    end
  end

  def parse_csv_line(line, csv_options)
    begin
      values = CSV.parse_line(line, csv_options).keep_if {|cell| cell.present?}
    rescue CSV::MalformedCSVError => e
      @parsing_error = true
      values = [line]
    end

    values
  end
end
