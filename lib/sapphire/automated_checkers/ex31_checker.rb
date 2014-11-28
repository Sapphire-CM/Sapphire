module Sapphire
  module AutomatedCheckers
    class Ex31Checker < Base
      checks_asset_files!

      content_type "text/email"

      prepare do
        @mail = Mail.new(subject.read)
      end

      check :no_strange_characters, "Body does not contain a \"|\"" do
        body = if @mail.multipart?
          part = @mail.parts.select {|part| part.content_type == 'text/plain'}.first
          part = @mail.parts.first if part.blank?
          part.body.to_s
        else
          @mail.body.to_s
        end

        failed! if body =~ /\|/
      end

      check :mail_to_wrong_tutor, "Email has not been sent to sapphire-submissions-inm-2014-ex31@iicm.edu" do
        mails = [@mail.to, @mail.cc].compact.flatten
        failed! if !mails.include?("sapphire-submissions-inm-2014-ex31@iicm.tu-graz.ac.at") && !mails.include?("sapphire-submissions-inm-2014-ex31@iicm.edu")
      end

      check :tutor_not_in_to, "sapphire-submissions-inm-2014@iicm.tu-graz.ac.at is in \"To\"" do
        failed! if !@mail.to.include?("sapphire-submissions-inm-2014-ex31@iicm.tu-graz.ac.at") && !@mail.to.include?("sapphire-submissions-inm-2014-ex31@iicm.edu")
      end

      check :mail_to_self, "Mail has been also sent to student" do
        success = false

        mails = [@mail.to, @mail.cc].flatten.compact.uniq.map(&:downcase)

        term_registrations.map(&:account).each do |account|
          emails_for_account = []
          emails_for_account << account.email
          emails_for_account += account.email_addresses.map(&:email)

          if (mails & emails_for_account).any?
            success = true
            break
          end
        end

        failed! unless success
      end

      check :mail_to_self_in_to, "Student's email is in \"To\"" do
        term_registrations.map(&:account).each do |account|
          emails = []
          emails << account.email
          emails += account.email_addresses.map(&:email)

          if (@mail.to & emails).any?
            failed!
            break
          end
        end
      end


      check :subject_present, "Subject is not empty" do
        failed! if @mail.subject.blank?
      end

      check :subject_conforming, "Subject conforms to \"inm-ws2014-tN-ex31-surname-forename-mnr\"" do
        success = false

        subject = @mail.subject
        term_registrations.each do |term_registration|
          student = term_registration.account
          subject_expected = "inm-ws2014-#{term_registration.tutorial_group.title}-ex31-#{to_ascii student.surname}-#{to_ascii student.forename.split(/[\s\-]+/,2).first}-#{student.matriculation_number}".downcase

          if subject == subject_expected
            success = true
            break
          end
        end
        failed! unless success
      end
    end
  end
end