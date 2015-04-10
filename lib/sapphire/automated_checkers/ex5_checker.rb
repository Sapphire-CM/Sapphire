module Sapphire
  module AutomatedCheckers
    class Ex5Checker < Base
      checks_asset_files!
      content_types 'text/email'

      prepare do
        @mail = Mail.new(subject.read)
      end

      check :subject_conforming, "Subject conforms to \"inm-ws2013-tN-ex5-surname-forename-mnr\"" do
        success = false

        subject = @mail.subject
        student_group.students.each do |student|
          subject_expected = "inm-ws2013-#{student_group.tutorial_group.title}-ex5-#{to_ascii student.surname}-#{to_ascii student.forename.split(/[\s\-]+/, 2).first}-#{student.matriculation_number}".downcase

          if subject == subject_expected
            success = true
            break
          end
        end
        failed! unless success
      end

      check :body_text, 'Body text is as specified' do
        body = if @mail.multipart?
          part = @mail.parts.find { |part| part.content_type == 'text/plain' }
          part = @mail.parts.first if part.blank?
          part.body.to_s
        else
          @mail.body.to_s
        end

        failed! unless body.include? "Dear Tutor,\n\nPlease find attached my three style sheets for Exercise 5."
      end
    end
  end
end
