class StaticController < ApplicationController
  def index
    flash.now[:notice] = "Success!"
    flash.now[:alert] = "Error!"
  end
end
