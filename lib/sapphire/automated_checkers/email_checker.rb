#encoding: utf-8

module Sapphire
  module AutomatedCheckers
    class EmailChecker < Base
      checks_asset_files!
      content_types "text/email", "text/newsgroup"

      prepare do
        @mail = Mail.new(subject.read)
      end

      check :real_name do
        success = false
        student_group.students.each do |student|
          from = @mail.header['From'].value.split("<",2).first.strip.downcase
          names = []
          names << student.forename.split(/s+/).first.downcase
          names << student.surname.split(/s+/).first.downcase


          names.compact.map {|n| n.force_encoding("UTF-8")}.each do |name|
            success = true if from.include? to_ascii(name)
          end

        end
        failed! unless success
        success! if success
      end

      check :redundant_reply_to_email_address do
        if @mail.header['Reply-To'] && !@mail.from.nil? && !@mail.header['Reply-To'].nil?
          if @mail.from.map(&:downcase).include? @mail.header['Reply-To'].to_s.downcase
            failed!
          end
        end
      end

      check :any_email_address_known do
        addresses = (@mail.from || []) + (@mail.reply_to || [])
        addresses.compact!
        addresses.map!(&:downcase)

        success = false
        student_group.students.each do |student|
          success = true if addresses.include? student.email
        end

        failed! unless success
      end

      check :contains_unknown_email do
        addresses = (@mail.from || []) + (@mail.reply_to || [])
        addresses.compact!
        addresses.uniq!
        addresses.map!(&:downcase)

        if addresses.length > 1
          failed!
        else
          address = addresses.first
          known = false
          student_group.students.each do |student|
            if student.email == address
              known = true
            end
          end

          failed! unless known
        end
      end

      check :body_utf8_charset do
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

      check :client do
        agent = @mail.header['User-Agent'].to_s

        if agent.present?
          # add bad agents here!
        else
          failed! if (h = @mail.header['NNTP-Posting-Host'].to_s).present? && h.include?("webnews")
        end
      end

      check :ascii_headers do
        if to_ascii(@mail.subject) == @mail.subject
          success!
        else
          failed!
        end
      end

      check :is_no_multipart do
        if @mail.parts.length > 1
          failed!
        end
      end

      check :signature_presence do
        body = if @mail.multipart?
          @mail.parts.select {|p| p.content_type =~ /plain/}.first.body
        else
          @mail.body
        end.to_s

        success = false
        body.split(/\n/).each do |line|
          success = true if line =~ /^\-{2,}\s*$/
        end

        failed! unless success
      end

      check :signature_length do
        body = if @mail.multipart?
          @mail.parts.select {|p| p.content_type =~ /plain/}.first.body
        else
          @mail.body
        end.to_s

        signature = body.scan(/^-- \n(.*)\z/m).last

        failed! if signature && signature.last.gsub(/\s+\z/, "").split(/\n/).count > 4

      end

      check :signature_separator do
        body = if @mail.multipart?
          @mail.parts.select {|p| p.content_type =~ /plain/}.first.body
        else
          @mail.body
        end.to_s

        sig_found = false
        body.split(/\n/).each do |line|
          sig_found = true if line =~ /^\-{2,}\s*$/
        end
        failed! if sig_found && body !~ /^-- $/
      end

      check :line_length do
        @mail.body.to_s.split("\n").each do |line|
          next if line.include? "http://"

          if line.length > 76
            failed!
            break
          end
        end
      end
    end
  end
end