module Sapphire
  module AutomatedCheckers
    class Ex31Checker < Base
      checks_asset_files!

      # content_type "text/email"

      prepare do
        @mail = Mail.new(subject.read)
      end

      check :no_strange_characters do
        body = if @mail.multipart?
          part = @mail.parts.select {|part| part.content_type == 'text/plain'}.first
          part = @mail.parts.first if part.blank?

          part.body.to_s
        else
          @mail.body.to_s
        end
        if body =~ /[^\w\s\-\.\,\/\:]/
          failed!
        else
          success!
        end
      end

      check :subject_present do
        failed! if @mail.subject.blank?
      end

      check :subject_conforming do
        success = false

        subject = @mail.subject
        student_group.students.each do |student|
          subject_expected = "inm-ws2013-#{student_group.tutorial_group.title}-ex31-#{to_ascii student.surname}-#{to_ascii student.forename.split(/[\s\-]+/,2).first}-#{student.matriculation_number}".downcase

          if subject == subject_expected
            success = true
            break
          end
        end
        failed! unless success
      end

      check :subject_7bit_ascii do
        failed! if @mail.subject =~ /[^a-zA-Z0-9\-]/
      end
    end
  end
end