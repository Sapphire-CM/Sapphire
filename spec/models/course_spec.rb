require 'rails_helper'

describe Course do
  describe 'db columns' do
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:locked).of_type(:boolean) }
  end

  it 'scopes to current term' do
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
    FactoryGirl.create(:term_registration, :tutor, account: account, term: t, tutorial_group: tg)

    t = terms[1]
    FactoryGirl.create(:term_registration, :lecturer, account: account, term: t)

    t = terms[2]
    tg = FactoryGirl.create(:tutorial_group, term: t)
    FactoryGirl.create(:term_registration, :student, account: account, term: t, tutorial_group: tg)

    expect(Course.associated_with(account).sort_by(&:id)).to eq(courses[0..2].sort_by(&:id))
  end

  it 'is able to determine whether a lecturer is associated with a course' do
    account = FactoryGirl.create(:account)
    term = FactoryGirl.create(:term)

    expect(term.course.associated_with? account).to be_falsey

    FactoryGirl.create(:term_registration, :lecturer, account: account, term: term)
    expect(term.course.associated_with? account).to be_truthy
  end

  context 'ordinary account' do
    let(:account) { FactoryGirl.create(:account) }

    it 'scopes all courses associated with an account when using viewable_for' do
      courses = FactoryGirl.create_list(:course, 5)
      terms = []
      terms << FactoryGirl.create(:term, course: courses[0])
      terms << FactoryGirl.create(:term, course: courses[1])
      terms << FactoryGirl.create(:term, course: courses[2])
      terms << FactoryGirl.create(:term, course: courses[3])
      terms << FactoryGirl.create(:term, course: courses[4])

      t = terms[0]
      tg = FactoryGirl.create(:tutorial_group, term: t)
      FactoryGirl.create(:term_registration, :tutor, account: account, term: t, tutorial_group: tg)

      t = terms[1]
      FactoryGirl.create(:term_registration, :lecturer, account: account, term: t)

      t = terms[2]
      tg = FactoryGirl.create(:tutorial_group, term: t)
      FactoryGirl.create(:term_registration, :student, account: account, term: t, tutorial_group: tg)

      expect(Course.viewable_for(account).sort_by(&:id)).to eq(courses.first(3))
    end
  end

  context 'admin account' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    it 'does not scope courses when using viewable_for' do
      courses = FactoryGirl.create_list(:course, 5)
      expect(Course.viewable_for(account).sort_by(&:id)).to eq(courses.sort_by(&:id))
    end
  end
end
