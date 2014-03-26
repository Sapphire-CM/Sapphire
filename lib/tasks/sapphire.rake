namespace :sapphire do
  desc "SAPPHIRE | Generates rating-group & rating seed for given exercise_id"
  task :generate_exercise_seed, :exercise_id do |t, args|
    exercise_id = args[:exercise_id]
    raise ArgumentError, "No exercise id given" unless exercise_id.present?
    ex = Exercise.find(exercise_id)


    seed = "# Seed for #{ex.title}\n\n"
    seed << "exercise = exercises[0]  # TODO: select correct exercise here!\n\n"

    rating_group_strings = []
    rating_strings = []
    ex.rating_groups.each_with_index do |rg, rg_idx|
      rating_group_strings << "  {title: #{rg.title.inspect}, points: #{rg.points}, exercise: exercise, global: #{rg.global?.to_s}, description: #{rg.description.inspect}, min_points: #{rg.min_points || "nil"}, max_points: #{rg.max_points || "nil"}, enable_range_points:#{rg.enable_range_points?.to_s}}"

      rg.ratings.each do |rating|
        rating_strings << "  {title: #{rating.title.inspect}, value: #{rating.value}, type: '#{rating.type}', rating_group: rating_groups[#{rg_idx}]}"
      end
    end

    seed << "rating_groups = RatingGroup.create([\n"
    seed <<  rating_group_strings.join(",\n")
    seed << "\n])"

    seed << "\n"*2

    seed << "ratings = Rating.create([\n"
    seed <<  rating_strings.join(",\n")
    seed << "\n])"
    fn = "exercise_seed_#{exercise_id}.rb"
    File.open(fn, "w") do |f|
      f.write seed
    end

    puts "Seed written to ./#{fn}"
  end

  desc "Auto Email Responder: process and respond to emails"
  task :auto_responder => :environment do |t, args|
    load 'lib/email/auto_responder.rb'

    case ENV['RESPONDER']
    when 'web_research'
      load 'lib/email/inm/web_research.rb'
    when 'style_sheets'
      load 'lib/email/inm/style_sheets.rb'
    else
      raise 'no responder type defined!'
    end

    new_mails.each do |mail|
      process_email mail
    end
  end

  desc "Imports students, student groups, and tutorial groups for term"
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

      student_import.import_result[:running] = false
      student_import.status = 'failed'
      student_import.save!
    end
  end
end
