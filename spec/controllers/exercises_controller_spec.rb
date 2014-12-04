require 'rails_helper'

describe ExercisesController do
  let(:term) { create(:term) }

  before :each do
    sign_in(user)
  end

  context "student" do
    let(:tutorial_group) { create(:tutorial_group, term: term) }
    let(:student_group) { create(:student_group, tutorial_group: tutorial_group) }
    let(:user) do
      account = create(:account)
      FactoryGirl.create(:student_registration, student: account, student_group: student_group)

      account
    end

    it "should assign @exercises" do
      exercises = FactoryGirl.create_list(:exercise, 5, term: term)

      get :index, term_id: term.id

      expect(assigns(:exercises)).to eq(exercises)
    end

    it "should assign @term" do
      get :index, term_id: term.id
      expect(assigns(:term)).to eq(term)
    end
  end
end
