class RatingsController < ApplicationController
  before_action :set_context
  before_action :set_rating, only: [:edit, :update, :update_position, :destroy]

  def new
    @rating = @rating_group.ratings.new
    authorize @rating
  end

  def create
    unless (params[:rating] && params[:rating][:type]) || Object.const_defined?(params[:rating][:type])
      @rating = @rating_group.ratings.new
      authorize @rating
      render :new, alert: 'Invalid type!'
      return
    end

    @rating = Rating.new_from_type(rating_params)
    @rating.rating_group = @rating_group
    @rating.row_order_position = :last
    authorize @rating

    if @rating.save
      render partial: 'ratings/insert_index_entry', locals: { rating: @rating }
    else
      render :new, alert: 'Error saving!'
    end
  end

  def edit
  end

  def update
    if @rating.update(rating_params)
      render partial: 'ratings/replace_index_entry', locals: { rating: @rating }
    else
      render :edit
    end
  end

  def update_position
    update_params = { rating_group_id: params[:rating][:rating_group_id], row_order_position: params[:rating][:position]}
    @rating.update(update_params)

    render text: "#{update_position_exercise_rating_group_rating_path(@exercise, @rating.rating_group, @rating)}"
  end

  def destroy
    @rating.destroy
    render partial: 'ratings/remove_index_entry', locals: { rating: @rating }
  end

  private
    def set_context
      @exercise = Exercise.find(params[:exercise_id])
      @rating_group = RatingGroup.find(params[:rating_group_id])
      @term = @exercise.term
    end

    def set_rating
      @rating = Rating.find(params[:id])
      authorize @rating
    end

    def rating_params
      params.require(:rating).permit(
        :rating_group_id,
        :title,
        :description,
        :value,
        :type,
        :min_value,
        :max_value,
        :multiplication_factor,
        :automated_checker_identifier)
    end

end
