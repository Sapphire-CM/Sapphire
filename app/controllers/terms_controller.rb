class TermsController < TermResourceController
  before_filter :fetch_course_term

  def show
    @tutorial_groups = @term.tutorial_groups
    @exercises = @term.exercises

    if @term.lecturer.blank?
      render alert: 'You have not set a lecturer yet!'
    end
  end

  def new
    @term = TermNew.new
    @term.course = @course
  end

  def create
    @term = TermNew.new(params[:term])

    if @term.save

      # create elements for new term
      if @term.copy_elements
        source_term = Term.find(@term.source_term_id)

        if @term.copy_lecturer
          source_registration = LecturerRegistration.find_by_term_id(source_term.id)

          if source_registration
            registration = LecturerRegistration.find_or_initialize_by_term_id(@term.id)
            registration.lecturer = source_registration.lecturer
            registration.registered_at = DateTime.now
            registration.save
          end
        end

        if @term.copy_exercises
          source_term.exercises.each do |source_exercise|
            exercise = source_exercise.dup
            exercise.term = @term
            exercise.save

            source_exercise.rating_groups.each do |source_rating_group|
              rating_group = source_rating_group.dup
              rating_group.exercise = exercise
              rating_group.save

              source_rating_group.ratings.each do |source_rating|
                rating = source_rating.dup
                rating.rating_group = rating_group
                rating.save
              end
            end
          end
        end
      end

      render partial: 'terms/insert_index_entry', locals: { term: @term }
    else
      render :new
    end
  end

  def edit
    # term is fetched with before_filter
  end

  def update
    if @term.update_attributes(params[:term])
      render partial: 'terms/replace_index_entry', locals: { term: @term }
    else
      render :edit
    end
  end

  def destroy
    @term.destroy

    render partial: 'terms/remove_index_entry', locals: { term: @term }
  end

  def new_lecturer_registration
    @accounts = Account.scoped.page(params[:page]).per(50)
    @accounts = @accounts.search(params[:q]) if params[:q].present?
  end

  def create_lecturer_registration
    @account = Account.find(params[:account_id])

    registration = LecturerRegistration.find_or_initialize_by_term_id(@term.id)
    registration.lecturer = @account
    registration.registered_at = DateTime.now

    if registration.save
      redirect_to course_term_path(current_course, current_term), notice: "Lecturer registration successfully added."
    else
      redirect_to course_term_path(current_course, current_term), alert: "Lecturer registration failed!"
    end
  end

  def clear_lecturer_registration
    @term.lecturer_registration.destroy

    redirect_to course_term_path(current_course, current_term), notice: "Lecturer registration successfully cleared!"
  end

  private

  def fetch_course_term
    @course = current_course
    @term = current_term
  end
end
