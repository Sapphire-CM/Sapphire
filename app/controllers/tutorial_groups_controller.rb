class TutorialGroupsController < ApplicationController
  include TermContext

  TutorialGroupPolicyRecord = Struct.new :user, :subject do
    def policy_class
      TutorialGroupPolicy
    end
  end

  before_action :set_context, only: [:show, :edit, :update, :destroy, :points_overview]

  def index
    @tutorial_groups = @term.tutorial_groups.merge policy_scope(TutorialGroup.all)
    authorize TutorialGroupPolicyRecord.new(current_account, current_term)
  end

  def show
    @student_groups = @tutorial_group.student_groups.order(:title)
    @student_term_registrations = @tutorial_group.student_term_registrations.ordered_by_name.with_accounts
  end

  def new
    @tutorial_group = TutorialGroup.new
    @tutorial_group.term = current_term
    authorize @tutorial_group
  end

  def create
    @tutorial_group = TutorialGroup.new(tutorial_group_params)
    @tutorial_group.term = current_term
    authorize @tutorial_group

    if @tutorial_group.save
      redirect_to term_tutorial_group_path(current_term, @tutorial_group), notice: "Tutorial group successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @tutorial_group.update(tutorial_group_params)
      redirect_to term_tutorial_group_path(current_term, @tutorial_group), notice: "Tutorial group successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @tutorial_group.destroy
    redirect_to @term, notice: "Tutorial group successfully deleted."
  end


  def points_overview
  end

  private

  def set_context
    @tutorial_group = current_term.tutorial_groups.find(params[:id] || params[:tutorial_group_id])
    authorize @tutorial_group
  end

  def tutorial_group_params
    params.require(:tutorial_group).permit(
      :term_id,
      :title,
      :description)
  end
end
