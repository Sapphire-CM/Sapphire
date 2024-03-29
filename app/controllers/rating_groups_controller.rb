class RatingGroupsController < ApplicationController
  include EventSourcing

  before_action :set_context
  before_action :set_rating_group, only: [:edit, :update, :destroy, :update_position]

  def index
    authorize RatingGroupPolicy.term_policy_record(@term)

    @rating_groups = @exercise.rating_groups
  end

  def new
    @rating_group = @exercise.rating_groups.new
    authorize @rating_group
  end

  def create
    @rating_group = @exercise.rating_groups.new(rating_group_params)
    @rating_group.row_order_position = :last
    authorize @rating_group

    if @rating_group.save
      event_service.rating_group_created!(@rating_group)
      render partial: 'rating_groups/insert_index_entry', locals: { rating_group: @rating_group }
    else
      render :new
    end
  end

  def edit
  end

  def update
    @rating_group.assign_attributes(rating_group_params)

    if @rating_group.valid?
      event_service.rating_group_updated!(@rating_group)
      @rating_group.save

      render partial: 'rating_groups/replace_index_entry', locals: { rating_group: @rating_group }
    else
      render :edit
    end
  end

  def update_position
    update_params = params.require(:rating_group).permit(:row_order_position)
    @rating_group.update update_params

    head :ok
  end

  def destroy
    @rating_group.destroy
    event_service.rating_group_destroyed!(@rating_group)
    render partial: 'rating_groups/remove_index_entry', locals: { rating_group: @rating_group }
  end

  private

  def set_context
    @exercise = Exercise.find(params[:exercise_id])
    @term = @exercise.term
  end

  def set_rating_group
    @rating_group = @exercise.rating_groups.find(params[:id])
    authorize @rating_group
  end

  def rating_group_params
    params.require(:rating_group).permit(
      :exercise_id,
      :title,
      :description,
      :global,
      :points,
      :min_points,
      :max_points,
      :enable_range_points)
  end
end
