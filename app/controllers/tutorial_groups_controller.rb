class TutorialGroupsController < TermResourceController
  def show
    @tutorial_group = current_term.tutorial_groups.find(params[:id])
  end
  
  def new
    @tutorial_group = current_term.tutorial_groups.new
  end
  
  
  def create
    @tutorial_group = current_term.tutorial_groups.new(params[:tutorial_group])
    
    if @tutorial_group.save
      redirect_to course_term_tutorial_group_path(current_course, current_term, @tutorial_group), :notice => "Tutorial group successfully created." 
    else
      render :new
    end
  end
  
  def edit
    @tutorial_group = current_term.tutorial_groups.find(params[:id])
  end
  
  def update
    @tutorial_group = current_term.tutorial_groups.find(params[:id])
    
    if @tutorial_group.update_attributes(params[:tutorial_group])
      redirect_to course_term_tutorial_group_path(current_course, current_term, @tutorial_group), :notice => "Tutorial group successfully updated."
    else
      render :edit
    end
  end
  
  def destroy
    @tutorial_group = current_term.tutorial_groups.find(params[:id])
    @tutorial_group.destroy
    redirect_to course_term_path(current_course, current_term), :notice => "Tutorial group successfully deleted."
  end
end
