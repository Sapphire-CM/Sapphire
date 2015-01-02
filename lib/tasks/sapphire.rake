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
end
