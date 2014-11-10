#encoding: utf-8

module Sapphire
  module AutomatedCheckers
    class EmailChecker < Base
      checks_asset_files!
      content_types "text/email", "text/newsgroup"

      prepare do
        @mail = Mail.new(subject.read)

        @extract_body = lambda {
          if @mail.multipart?
            part = @mail.parts.select {|part| part.content_type == 'text/plain'}.first
            part = @mail.parts.first if part.blank?
            part.body.to_s
          else
            @mail.body.to_s
          end
        }
      end

      check :real_name, "Real name in \"From:\"" do
        # real name is one firstname and lastname
        success = false
        term_registrations.each do |term_registration|
          student = term_registration.account
          from = @mail.header['From'].value.split("<",2).first.strip.downcase
          names = []
          names << student.forename.split(/s+/).first.downcase
          names << student.surname.split(/s+/).first.downcase

          names.compact.map {|n| n.force_encoding("UTF-8")}.each do |name|

            name.split(/\s+/).each do |split_name|
              if from.include? to_ascii(split_name)
                success = true
                break
              end
            end

          end

        end
        failed! unless success
        success! if success
      end

      check :redundant_reply_to_email_address, "\"Reply-To\" does not contains a redundant email address" do
        if @mail.header['Reply-To'] && !@mail.from.nil? && !@mail.header['Reply-To'].nil?
          if @mail.from.map(&:downcase).include? @mail.header['Reply-To'].to_s.downcase
            failed!
          end
        end
      end

      check :any_email_address_known, "\"From\" or \"Reply-To\" contains a known email address" do
        addresses = (@mail.from || []) + (@mail.reply_to || [])
        addresses.compact!
        addresses.map!(&:downcase)

        success = false
        term_registrations.each do |term_registration|
          student = term_registration.account
          success = true if addresses.include? student.email
        end

        failed! unless success
        # returns unkown if success = true
      end

      check :contains_unknown_email, "Doesn't contain unknown email address in from or reply to" do
        addresses = (@mail.from || []) + (@mail.reply_to || [])
        addresses.compact!
        addresses.uniq!
        addresses.map!(&:downcase)

        if addresses.length > 1
          failed!
        else
          address = addresses.first
          known = false
          term_registrations.map(&:account).each do |student|
            if student.email == address
              known = true
            end
          end

          failed! unless known
        end
      end

      check :body_utf8_charset, "Charset in body is UTF-8" do
        if ct = @mail.header['Content-Type'].to_s.downcase
          failed! unless ct.include? "charset=utf-8"
        end

        if @mail.multipart?
          @mail.parts.each do |part|
            if part.content_type.downcase.include?("charset=iso")
              failed!
              break
            end
          end
        end
      end

      check :client, "Correct email- or newsgroup-client" do
        agent = @mail.header['User-Agent'].to_s

        if agent.present?
          failed! if agent =~ /Internet Messaging Program/
        else
          failed! if (h = @mail.header['NNTP-Posting-Host'].to_s).present? && h.include?("webnews")
        end
      end

      check :ascii_headers, "Headers contain only ASCII characters" do
        if to_ascii(@mail.subject) == @mail.subject
          success!
        else
          failed!
        end
      end

      check :has_no_html_part, "Has no HTML part" do
        if @mail.parts.length > 1
          @mail.parts.each do |part|
            if part.content_type !~ /plain/i
              failed!
              break
            end
          end
        end
      end

      check :signature_presence, "Any signature present?" do
        body = @extract_body.call.to_s

        success = false
        body.split(/\n/).each do |line|
          success = true if line =~ /^\-{2,}\s*$/
        end

        failed! unless success
      end

      check :signature_length, "Signature has less than 4 lines" do
        body = @extract_body.call.to_s

        signature = body.scan(/^-- \n(.*)^-/m).last   # may be Antivirus-Footer
        if signature.blank?
          signature = body.scan(/^-- \n(.*)\z/m).last
        end

        failed! if signature && signature.last.gsub(/\s+\z/, "").split(/\n/).count > 4

      end

      check :signature_separator, "Signature seperator is \"-- \"" do
        body = @extract_body.call.to_s

        sig_found = false
        body.split(/\n/).each do |line|
          sig_found = true if line =~ /^\-{2,}\s*$/
        end
        failed! if sig_found && body !~ /^-- $/
      end

      check :line_length, "Line length is below 76 characters" do
        @extract_body.call.to_s.split(/\n/).each do |line|
          next if line =~ /(http|https|ftp|news):\/\//

          if line.length >= 76
            failed!
            break
          end
        end
      end


      check :subject_7bit_ascii, "Subject contains only 7-bit ASCII characters" do
        failed! if to_ascii(@mail.subject) != @mail.subject
      end
    end
  end
end
