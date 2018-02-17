class DiskUsageController < ApplicationController
	include ExerciseContext

	def index
  	authorize DiskUsagePolicy.with(current_term)
	end

end
