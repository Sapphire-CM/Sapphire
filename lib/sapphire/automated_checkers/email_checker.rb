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
        if @mail.respond_to? :reply_to
          if @mail.reply_to == @mail.from
            failed!
          end
        end
      end

      check :email_address do

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
        if @mail.subject =~ /\A[A-Za-z0-9\s]\z/
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

      end

      check :signature_length do

      end

      check :signature_separator do

      end

      check :line_length do

      end
    end
  end
end