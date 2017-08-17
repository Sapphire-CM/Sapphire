class ServerStatusController < ApplicationController


	def index
		authorize Account #?	

	end 

	def filesystem
		"/boot"
	end
	helper_method :filesystem

	def get_df
		df = `df #{filesystem}`
		line = df.split(/\n/)[1]
		byte_values = line.match(/(.+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
		mbs = byte_values[3..4].collect{ |d| d.to_i / 1024}
		mbs.push(byte_values[5])
	end
	helper_method :get_df
=begin
	def current_term
		Term.last
	end

	def exercise_submissions(exercise)
		Submission.select(:id).where(exercise_id: exercise)
	end
	helper_method :exercise_submissions

	def submission_size(submission)
		SubmissionAsset.where(submission_id: submission).sum("processed_size")
	end
	helper_method :submission_size
=end


	end