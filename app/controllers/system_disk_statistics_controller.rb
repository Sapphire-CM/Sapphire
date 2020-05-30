class SystemDiskStatisticsController < ApplicationController
  before_action :set_terms, only: [:index]

  def index
    puts "index here!"
  end

  private
    def set_terms
      puts "set here!"
      @account = Account.find(params[:id])
      authorize @account
    end
end
