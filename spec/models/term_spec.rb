require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Term do
  it { should have_many(:term_registrations) }

  context "ordinary account" do
    let(:account) { FactoryGirl.create(:account) }

    it "should scope all terms associated with an account" do
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

    it "should be able to determine whether an account is associated with this term" do
      term = FactoryGirl.create(:term)

      expect(term.associated_with? account).to be_falsey
      tg = FactoryGirl.create(:tutorial_group, term: term)
      FactoryGirl.create(:term_registration, :tutor, account: account, term: term, tutorial_group: tg)

      expect(term.associated_with? account).to be_truthy
    end
  end
end