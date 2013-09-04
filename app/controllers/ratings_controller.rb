class RatingsController < TermResourceController
  before_action :fetch_exercise, :fetch_rating_group

  def new
    @rating = @rating_group.ratings.new
  end

  def create
    unless (params[:rating] && params[:rating][:type]) || Object.const_defined?(params[:rating][:type])
      @rating = @rating_group.ratings.new
      render :new, alert: 'Invalid type!'
      return
    end

    @rating = Rating.new_from_type(params[:rating])
    @rating.rating_group = @rating_group
    @rating.row_order_position = :last

    if @rating.save
      render partial: 'ratings/insert_index_entry', locals: { rating: @rating }
    else
      render :new, alert: 'Error saving!'
    end
  end

  def edit
    @rating = @rating_group.ratings.find(params[:id])
  end

  def update
    @rating = @rating_group.ratings.find(params[:id])

    if @rating.update_attributes(params[:rating])
      render partial: 'ratings/replace_index_entry', locals: { rating: @rating }
    else
      render :edit
    end
  end

  def update_position
    @rating = @exercise.ratings.find(params[:id])

    update_params = { rating_group_id: params[:rating][:rating_group_id], row_order_position: params[:rating][:position]}
    @rating.update_attributes(update_params)

    render text: "#{update_position_exercise_rating_group_rating_path(@exercise, @rating.rating_group, @rating)}"
  end

  def destroy
    @rating = @rating_group.ratings.find(params[:id])
    @rating.destroy

    render partial: 'ratings/remove_index_entry', locals: { rating: @rating }
  end

  private
  def fetch_exercise
    @exercise = current_term.exercises.find(params[:exercise_id])
  end

  def fetch_rating_group
    @rating_group = @exercise.rating_groups.find(params[:rating_group_id])
  end

end
