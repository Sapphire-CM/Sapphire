class TermsController < TermResourceController
  before_action :fetch_course_term

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
      if not @term.copy_elements.to_i.zero?
        source_term = Term.find(@term.source_term_id)

        source_term.copy_lecturer(@term) if not @term.copy_lecturer.to_i.zero?
        source_term.copy_exercises(@term) if not @term.copy_exercises.to_i.zero?
        source_term.copy_grading_scale(@term) if not @term.copy_grading_scale.to_i.zero?
      end

      render partial: 'terms/insert_index_entry', locals: { term: @term }
    else
      render :new
    end
  end

  def edit
    # term is fetched with before_action
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
      redirect_to term_path(current_term), notice: "Lecturer registration successfully added."
    else
      redirect_to term_path(current_term), alert: "Lecturer registration failed!"
    end
  end

  def clear_lecturer_registration
    @term.lecturer_registration.destroy

    redirect_to term_path(current_term), notice: "Lecturer registration successfully cleared!"
  end

  def update_grading_scale
    grade = params[:grading_scale].to_a[0][0]
    low = params[:grading_scale].to_a[0][1]

    pair = @term.grading_scale.select{|l,g| g == grade}.first
    @term.grading_scale.delete pair
    @term.grading_scale << [low.to_i, grade]
    @term.save!
  end

  private

  def fetch_course_term
    @course = current_course
    @term = current_term
  end
end
