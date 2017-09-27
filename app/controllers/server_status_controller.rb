require 'rubygems'
require 'sys/filesystem'

class ServerStatusController < ApplicationController
	include Sys

	def index
		authorize ServerStatusPolicy.with(current_account)

		@status = Filesystem.stat("/")
		@terms = Term.all
	end
end
