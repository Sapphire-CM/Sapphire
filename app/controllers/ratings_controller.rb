class RatingsController < ApplicationController
  RatingPolicyRecord = Struct.new :rating do
    def policy_class
      RatingPolicy
    end
  end

  before_action :set_context
  before_action :set_rating, only: [:edit, :update, :update_position, :destroy]

  def new
    @rating = @rating_group.ratings.new
    authorize RatingPolicyRecord.new @rating
  end

  def create
    unless params[:rating] && params[:rating][:type] && Object.const_defined?(params[:rating][:type].classify)
      @rating = @rating_group.ratings.new
      authorize RatingPolicyRecord.new @rating
      render :new, alert: 'Invalid type!'
      return
    end

    @rating = Rating.new_from_type(rating_params)
    @rating.rating_group = @rating_group
    @rating.row_order_position = :last
    authorize RatingPolicyRecord.new @rating

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
    update_params = params.require(:rating).permit(:rating_group_id, :row_order_position)
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
      authorize RatingPolicyRecord.new @rating
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
