require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Course do
  it "should scope to current term" do
    account = FactoryGirl.create(:account)

    courses = FactoryGirl.create_list(:course, 5)
    terms = []
    terms << FactoryGirl.create(:term, course: courses[0])
    terms << FactoryGirl.create(:term, course: courses[1])
    terms << FactoryGirl.create(:term, course: courses[2])
    terms << FactoryGirl.create(:term, course: courses[3])
    terms << FactoryGirl.create(:term, course: courses[4])

    t = terms[0]
    tg = FactoryGirl.create(:tutorial_group, term: t)
    FactoryGirl.create(:tutor_registration, tutor: account, tutorial_group: tg)

    t = terms[1]
    FactoryGirl.create(:lecturer_registration, lecturer: account, term: t)

    t = terms[2]
    tg = FactoryGirl.create(:tutorial_group, term: t)
    sg = FactoryGirl.create(:student_group, tutorial_group: tg)
    sgr = FactoryGirl.create(:student_registration, student: account, student_group: sg)

    expect(Course.associated_with(account).sort_by(&:id)).to eq(courses.first(3))
  end

  it "should be able to determine whether a student is associated with a course" do
    account = FactoryGirl.create(:account)
    term = FactoryGirl.create(:term)

    expect(term.course.associated_with? account).to be_false

    lecturer_registration = FactoryGirl.create(:lecturer_registration, term: term)
    expect(term.course.associated_with? lecturer_registration.lecturer).to be_true
  end

  context "ordinary account" do
    let(:account) { FactoryGirl.create(:account) }

    it "should scope all courses associated with an account when using viewable_for" do
      courses = FactoryGirl.create_list(:course, 5)
      terms = []
      terms << FactoryGirl.create(:term, course: courses[0])
      terms << FactoryGirl.create(:term, course: courses[1])
      terms << FactoryGirl.create(:term, course: courses[2])
      terms << FactoryGirl.create(:term, course: courses[3])
      terms << FactoryGirl.create(:term, course: courses[4])

      t = terms[0]
      tg = FactoryGirl.create(:tutorial_group, term: t)
      FactoryGirl.create(:tutor_registration, tutor: account, tutorial_group: tg)

      t = terms[1]
      FactoryGirl.create(:lecturer_registration, lecturer: account, term: t)

      t = terms[2]
      tg = FactoryGirl.create(:tutorial_group, term: t)
      sg = FactoryGirl.create(:student_group, tutorial_group: tg)
      sgr = FactoryGirl.create(:student_registration, student: account, student_group: sg)

      expect(Course.viewable_for(account).sort_by(&:id)).to eq(courses.first(3))
    end
  end

  context "admin account" do
    let(:account) { FactoryGirl.create(:account, :admin) }

    it "should not scope courses when using viewable_for" do
      courses = FactoryGirl.create_list(:course, 5)
      expect(Course.viewable_for(account).sort_by(&:id)).to eq(courses)
    end
  end
end