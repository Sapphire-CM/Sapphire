When(/^I am moved into another student group$/) do
  @acc.student_groups.active.where(solitary: false).count.should eq 1
  student_group = @acc.student_groups.active.where(solitary: false).first
  student_group.update(active: false).should be_true

  term = student_group.term

  tutorial_group = FactoryGirl.create(:tutorial_group, term: term)

  new_student_group = FactoryGirl.create(:student_group, tutorial_group: tutorial_group, solitary: false, active: true)
  FactoryGirl.create(:student_registration, student: @acc, student_group: new_student_group)

  @acc.student_groups.active.where(solitary: false).count.should eq 1
  @acc.student_groups.active.where(solitary: false).first.should eq new_student_group
end
