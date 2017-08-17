module DiskUsageHelper
	def get_df
		@df = `(df -PTh | column -t | sort -n -k6n) | sed 's/ / &nbsp; /g' | sed 's/^/<br>/'`
		@df.html_safe
	end

	def current_term_exercises
		@exercises = Exercise.where(term_id: current_term).to_a
	end

	def term_exercises
		Exercise.where(term_id: @term)
	end

	def term_student_groups
		tutorial_group_ids = TutorialGroup.select(:id).where(term_id: @term)
		term_student_groups = []
		tutorial_group_ids.each do |t|
			term_student_groups.push(*StudentGroup.where(tutorial_group_id: t).to_a)
		end

		term_student_groups
	end

	def exercise_submissions(exercise)
		Submission.select(:id).where(exercise_id: exercise)
	end
	

	def submission_size(submission)
		SubmissionAsset.where(submission_id: submission).sum("processed_size")
	end
	
	def exercise_submission_size(exercise, student_group)
		submission_ids = Submission.where(exercise_id: exercise.id, student_group_id: student_group.id)
		size = SubmissionAsset.where(submission_id: submission_ids).sum("processed_size")
		unless size.zero?
			size
		else
			"Empty"
		end
	end

	def exercise_upload_sizes(exercise)
		submissions = exercise_submissions(exercise)
		submission_sizes = []
		submissions.each do |submission|
			submission_sizes.push(submission_size(submission))
			end

		submission_sizes
	end

	def exercise_mean_upload_size(exercise)
		submissions = exercise_upload_sizes(exercise) #?
		sum = 0
		submissions.each do |submission|
			sum += submission
		end
		sum /= submissions.count unless sum.zero?
		sum		
	end

	def exercise_max_upload_size(exercise)
		exercise_upload_sizes(exercise).max
	end

	def exercise_min_upload_size(exercise)
		exercise_upload_sizes(exercise).min
	end

	def exercise_sum_upload_size(exercise)
		exercise_upload_sizes(exercise).sum
	end

end