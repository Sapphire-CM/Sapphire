require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Exercise do
  it "should be able to set student uploads" do
    exercise = FactoryGirl.create(:exercise, allow_student_uploads: true)
    exercise.allow_student_uploads?.should be_true

    exercise = FactoryGirl.create(:exercise, allow_student_uploads: false)
    exercise.allow_student_uploads?.should be_false
  end

end