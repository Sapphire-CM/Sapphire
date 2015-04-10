class ServicesController < ApplicationController
  include ExerciseContext

  before_action :fetch_service, only: [:edit, :update]

  def index
    authorize ServicePolicy.with(current_term)

    @services = current_exercise.services
  end

  def edit
  end

  def update
    if @service.update(service_params)
      redirect_to term_exercise_services_path(current_term, current_exercise)
    else
      render :edit
    end
  end

  private
  def fetch_service
    @service = current_exercise.services.find(params[:id])
    authorize @service
  end

  def service_params
    params.require(:service).permit [:active] + @service.class.properties
  end
end
