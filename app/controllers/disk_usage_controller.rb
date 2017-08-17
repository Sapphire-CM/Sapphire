class DiskUsageController < ApplicationController
	include TermContext

	def index
		authorize Account
	end

	def show		
	end

	def render_exercise
		authorize DiskUsage #?
		respond_to do |format|
			format.js
		end
	end
	

end
