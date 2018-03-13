require 'rails_helper'

RSpec.describe BulkGradings::SubjectsFinder, :doing do
  describe 'initialization' do
    let(:exercise) { instance_double(Exercise) }
    it 'accepts an exercise' do
      subject = described_class.new(exercise: exercise)

      expect(subject.exercise).to eq(exercise)
    end
  end

  describe 'methods' do
    subject { described_class.new(exercise: exercise) }

    let(:term) { FactoryGirl.create(:term) }
    let(:other_term) { FactoryGirl.create(:term) }

    describe '#search' do
      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let(:other_tutorial_group) { FactoryGirl.create(:tutorial_group, term: other_term) }

      let(:student_group_g1_01) { FactoryGirl.create(:student_group, title: "G1-01", tutorial_group: tutorial_group) }
      let(:student_group_g1_02) { FactoryGirl.create(:student_group, title: "G1-02", tutorial_group: tutorial_group) }
      let(:student_group_g5_02) { FactoryGirl.create(:student_group, title: "G5-02", tutorial_group: tutorial_group) }
      let(:other_student_group_g5_02) { FactoryGirl.create(:student_group, title: "G5-02", tutorial_group: other_tutorial_group) }

      let!(:student_groups) { [student_group_g1_01, student_group_g1_02, student_group_g5_02] }
      let!(:other_student_groups) { [other_student_group_g5_02] }

      let(:student_account_1) { FactoryGirl.create(:account, email: "hs@example.com", matriculation_number: "12345678", forename: "Homer", surname: "Simpson") }
      let(:student_account_2) { FactoryGirl.create(:account, email: "ms@example.com", matriculation_number: "12345679", forename: "Marge", surname: "Simpson") }
      let(:student_account_3) { FactoryGirl.create(:account, email: "mf@example.com", matriculation_number: "13345679", forename: "Maude", surname: "Flanders") }
      let(:student_account_4) { FactoryGirl.create(:account, email: "nf@example.com", matriculation_number: "13345680", forename: "Ned", surname: "Flanders") }

      let(:term_registration_1) { FactoryGirl.create(:term_registration, :student, account: student_account_1, term: term) }
      let(:term_registration_2) { FactoryGirl.create(:term_registration, :student, account: student_account_2, term: term) }
      let(:term_registration_3) { FactoryGirl.create(:term_registration, :student, account: student_account_3, term: term) }
      let(:term_registration_4) { FactoryGirl.create(:term_registration, :student, account: student_account_4, term: other_term) }

      let!(:term_registrations) { [term_registration_1, term_registration_2, term_registration_3] }
      let!(:other_term_registrations) { [term_registration_4] }

      context 'with group exercise' do
        let(:exercise) { FactoryGirl.build(:exercise, :group_exercise, term: term) }

        it 'returns student groups with matching prefix' do
          expect(subject.search("G1-")).to match_array([student_group_g1_01, student_group_g1_02])
        end

        it 'returns student groups with partial match' do
          expect(subject.search("-0")).to match_array(student_groups)
        end

        it 'returns student groups with matching suffix' do
          expect(subject.search("-02")).to match_array([student_group_g1_02, student_group_g5_02])
        end

        it 'does not return student groups from other terms' do
          expect(subject.search("G5-02")).not_to include(other_student_group_g5_02)
        end
      end

      context 'with solitary exercise' do
        let(:exercise) { FactoryGirl.build(:exercise, :solitary_exercise, term: term) }

        it 'returns term_registrations with matching matriculation numbers' do
          expect(subject.search("345")).to match_array(term_registrations)
          expect(subject.search("123")).to match_array([term_registration_1, term_registration_2])
          expect(subject.search("679")).to match_array([term_registration_2, term_registration_3])
        end

        it 'returns term_registrations with matching surnames' do
          expect(subject.search("Simpson")).to match_array([term_registration_1, term_registration_2])
          expect(subject.search("Flanders")).to match_array([term_registration_3])
        end

        it 'returns term_registrations with matching forenames' do
          expect(subject.search("Homer")).to match_array([term_registration_1])
          expect(subject.search("Ma")).to match_array([term_registration_2, term_registration_3])
        end

        it 'returns term_registrations with matching emails' do
          expect(subject.search("hs@example.com")).to match_array([term_registration_1])
        end

        it 'does not return term_registrations of other terms' do
          expect(subject.search("Ned")).not_to include(term_registration_4)
        end
      end
    end

    describe '#find' do
      context 'with group exercise' do
        let(:exercise) { FactoryGirl.build(:exercise, :group_exercise, term: term) }
        let(:student_groups) { FactoryGirl.create_list(:student_group, 3, term: term) }
        let(:other_student_groups) { FactoryGirl.create_list(:student_group, 3) }

        it 'returns student groups' do
          expect(subject.find(student_groups[0..1].map(&:id))).to match_array(student_groups[0..1])
        end

        it 'raises an error if student group belongs to another term' do
          expect do
            subject.find(other_student_groups.map(&:id))
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with solitary exercise' do
        let(:exercise) { FactoryGirl.build(:exercise, :solitary_exercise, term: term) }

        let(:student_account_1) { FactoryGirl.create(:account, :student) }
        let(:student_account_2) { FactoryGirl.create(:account, :student) }
        let(:student_account_3) { FactoryGirl.create(:account, :student) }
        let(:student_account_4) { FactoryGirl.create(:account, :student) }

        let(:term_registration_1) { FactoryGirl.create(:term_registration, :student, account: student_account_1, term: term) }
        let(:term_registration_2) { FactoryGirl.create(:term_registration, :student, account: student_account_2, term: term) }
        let(:term_registration_3) { FactoryGirl.create(:term_registration, :student, account: student_account_3, term: term) }
        let(:term_registration_4) { FactoryGirl.create(:term_registration, :student, account: student_account_4, term: other_term) }

        let!(:term_registrations) { [term_registration_1, term_registration_2, term_registration_3] }
        let!(:other_term_registrations) { [term_registration_4] }

        it 'returns term registrations' do
          expect(subject.find(term_registrations[0..1].map(&:id))).to match_array(term_registrations[0..1])
        end

        it 'raises an error if term registration belongs to another term' do
          expect do
            subject.find(other_term_registrations.map(&:id))
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

end