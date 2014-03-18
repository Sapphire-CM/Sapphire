Given(/^I am a student of "(.*?)" in term "(.*?)"$/) do |course_title, term_title|
  unless @acc
    @acc = FactoryGirl.create(:account, :student)
  end


  course = FactoryGirl.create(:course, title: title) unless course = Course.where(title: course_title).first
  term = FactoryGirl.create(:term, course: course) unless term = course.terms.where(title: term_title).first

  tutorial_group = FactoryGirl.create(:tutorial_group, term: term)
  student_group = FactoryGirl.create(:student_group, tutorial_group: tutorial_group)
  student_registration = FactoryGirl.create(:student_registration, student: @acc, student_group: student_group)
end