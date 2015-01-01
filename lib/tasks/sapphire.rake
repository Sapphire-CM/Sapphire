namespace :sapphire do
  desc 'Auto Email Responder: process and respond to emails'
  task :auto_responder, [:exercise_id, :responder] => :environment do |t, args|
    load 'lib/email/auto_responder.rb'

    case args[:responder]
    when 'web_research'
      load 'lib/email/inm/web_research.rb'
    else
      raise 'no responder type defined!'
    end

    exercise = Exercise.find(args[:exercise_id])

    new_mails(exercise).each do |mail|
      process_email mail, exercise
    end
  end

  desc 'Imports students, student groups, and tutorial groups for term'
  task :import_students, [:student_import_id] => :environment do |t, args|
    student_import_id = args[:student_import_id]
    raise ArgumentError, "No student_import id given" unless student_import_id.present?
    student_import = Import::StudentImport.find(student_import_id)
    raise ArgumentError, "No student_import found" unless student_import.present?

    puts "#{Time.now}: Importing ID #{student_import.id}..."

    begin
      student_import.import
      puts "#{Time.now}: Importing ID #{student_import.id} done."
    rescue Exception => ex
      puts ex
      puts "#{Time.now}: Importing ID #{student_import.id} failed."

      student_import.status = :failed
      student_import.save!
    end
  end
end
