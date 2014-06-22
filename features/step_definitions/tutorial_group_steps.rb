Given(/^there are these tutorial groups for term "(.*?)" of course "(.*?)"$/) do |term_title, course_title, table|
  course = FactoryGirl.create(:course, title: course_title) unless course = Course.where(title: course_title).first
  term = FactoryGirl.create(:term, title: term_title, course: course) unless term = course.terms.where(title: term_title).first

  table.hashes.each do |line|
    FactoryGirl.create(:tutorial_group, term: term, title: line['title']) unless term.tutorial_groups.where(title: line['title']).first
  end
end
