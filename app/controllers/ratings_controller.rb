class RatingsController < TermResourceController
  before_filter :fetch_exercise, :fetch_rating_group

  def index
    @ratings = @rating_group.ratings.all
  end

  def show
    @rating = @rating_group.ratings.find(params[:id])
  end

  def new
    @rating = @rating_group.ratings.new
  end

  def edit
    @rating = @rating_group.ratings.find(params[:id])
  end

  def create
    @rating = @rating_group.ratings.new(params[:rating])

    if @rating.save
      redirect_to course_term_exercise_rating_group_path(current_course, current_term, @exercise, @rating_group), :notice => "Rating was successfully created."
    else
      render :new
    end
  end

  def update
    @rating = @rating_group.ratings.find(params[:id])

    if @rating.update_attributes(params[:rating])
      redirect_to course_term_exercise_rating_group_path(current_course, current_term, @exercise, @rating_group), :notice => "Rating was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @rating = @rating_group.ratings.find(params[:id])
    @rating.destroy

    redirect_to course_term_exercise_rating_group_path(current_course, current_term, @exercise, @rating_group), :notice => "Rating was successfully deleted."
  end

  private
  def fetch_exercise
    @exercise = current_term.exercises.find(params[:exercise_id])
  end

  def fetch_rating_group
    @rating_group = @exercise.rating_groups.find(params[:rating_group_id])
  end

end
