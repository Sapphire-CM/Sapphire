class SystemDiskStatisticsController < ApplicationController
  before_action :set_courses, only: [:index]

  def index
    authorize Account
  end

  private
    def set_courses
      @courses = Course.all
    end
end
