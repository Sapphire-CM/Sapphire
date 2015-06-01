require 'rails_helper'

describe Term do
  it { is_expected.to have_many(:term_registrations) }

  context 'grading_scales' do
    it 'creates all grading_scales with after_create' do
      course = FactoryGirl.create :course
      term = course.terms.create! title: 'new term'

      expect(term.grading_scales.length).to eq(6)
      expect(term.grading_scales.where(not_graded: true).length).to eq(1)
      expect(term.grading_scales.where(positive: false, not_graded: false).length).to eq(1)
      expect(term.grading_scales.where(positive: true, not_graded: false).length).to eq(4)
      expect(term.grading_scales.positives.length).to eq(4)
      expect(term.grading_scales.pluck(:grade)).to match_array(%w(1 2 3 4 5 0))
      expect(term.valid_grading_scales?).to eq(true)
    end
  end

  context 'ordinary account' do
    let(:account) { FactoryGirl.create(:account) }

    it 'scopes all terms associated with an account' do
      terms = FactoryGirl.create_list(:term, 5)

      t = terms[0]
      tg = FactoryGirl.create(:tutorial_group, term: t)
      FactoryGirl.create(:term_registration, :tutor, account: account, term: t, tutorial_group: tg)

      t = terms[1]
      FactoryGirl.create(:term_registration, :lecturer, account: account, term: t)

      t = terms[2]
      tg = FactoryGirl.create(:tutorial_group, term: t)
      FactoryGirl.create(:term_registration, :student, account: account, term: t, tutorial_group: tg)

      expect(Term.associated_with(account).sort_by(&:id)).to eq(terms.first(3))
    end

    it 'is able to determine whether an account is associated with this term' do
      term = FactoryGirl.create(:term)

      expect(term.associated_with? account).to be_falsey
      tg = FactoryGirl.create(:tutorial_group, term: term)
      FactoryGirl.create(:term_registration, :tutor, account: account, term: term, tutorial_group: tg)

      expect(term.associated_with? account).to be_truthy
    end
  end
end
