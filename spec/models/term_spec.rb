require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Term do
  it { should have_many(:term_registrations) }

  context "ordinary account" do
    let(:account) { FactoryGirl.create(:account) }

    it "should scope all terms associated with an account" do
      terms = FactoryGirl.create_list(:term, 5)

      t = terms[0]
      tg = FactoryGirl.create(:tutorial_group, term: t)
      FactoryGirl.create(:tutor_registration, tutor: account, tutorial_group: tg)

      t = terms[1]
      FactoryGirl.create(:lecturer_registration, lecturer: account, term: t)


      t = terms[2]
      tg = FactoryGirl.create(:tutorial_group, term: t)
      sg = FactoryGirl.create(:student_group, tutorial_group: tg)
      sgr = FactoryGirl.create(:student_registration, student: account, student_group: sg)

      expect(Term.associated_with(account).sort_by(&:id)).to eq(terms.first(3))
    end

    it "should be able to determine whether an account is associated with this term" do
      term = FactoryGirl.create(:term)

      expect(term.associated_with? account).to be_false
      tg = FactoryGirl.create(:tutorial_group, term: term)
      FactoryGirl.create(:tutor_registration, tutorial_group: tg, tutor: account)

      expect(term.associated_with? account).to be_true
    end
  end
end