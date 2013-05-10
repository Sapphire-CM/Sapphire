class RatingGroupsController < TermResourceController
  before_filter :fetch_exercise

  def show
    @rating_group = @exercise.rating_groups.find(params[:id])
  end

  def edit
    @rating_group = @exercise.rating_groups.find(params[:id])
  end

  def create
    @rating_group = @exercise.rating_groups.new(params[:rating_group])

    if @rating_group.save
      render partial: 'rating_groups/index_entry', locals: { rating_group: @rating_group}
    else
      #todo adapt to ajax
      render :new
    end
  end

  def update
    @rating_group = @exercise.rating_groups.find(params[:id])

    if @rating_group.update_attributes(params[:rating_group])
      #todo adapt to ajax
      redirect_to course_term_exercise_rating_group_path(current_course, current_term, @exercise, @rating_group), notice: "RatingGroup was successfully updated."
    else
      #todo adapt to ajax
      render :edit
    end
  end

  def destroy
    @rating_group = @exercise.rating_groups.find(params[:id])
    @rating_group.destroy

    respond_to do |format|
      format.js do
        render nothing: true
      end
      format.html do
        redirect_to course_term_exercise_rating_groups_path(current_course, current_term, @exercise), notice: "RatingGroup was successfully deleted."
      end
    end
  end

  private
  def fetch_exercise
    @exercise = current_term.exercises.find(params[:exercise_id])
  end

end
