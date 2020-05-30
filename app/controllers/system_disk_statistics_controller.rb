class SystemDiskStatisticsController < ApplicationController
  before_action :set_terms, only: [:index]

  def index
    authorize Account
  end

  private
    def set_terms
      @courses = Course.all
    end
end
