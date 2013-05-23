class RatingsController < TermResourceController
  before_filter :fetch_exercise, :fetch_rating_group

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
