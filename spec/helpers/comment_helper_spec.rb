require 'rails_helper'

RSpec.describe CommentsHelper, type: :helper do
  let(:account) { FactoryBot.create(:account, :admin) }

  describe 'comment buttons' do
    let(:evaluation) { FactoryBot.create :fixed_evaluation }

    describe 'internal' do
      let(:submission_evaluation) { FactoryBot.create :submission_evaluation }
      context 'without comment' do
        it 'sets the correct title and classes' do
          html = helper.internal_comment_button(submission_evaluation)

          expect(html).to include('Add Internal Note')
          expect(html).to include('class="small button"')
        end
      end

      context 'with comment' do
        let!(:comment) { FactoryBot.create :notes_comment, account: account, commentable: submission_evaluation }
        it 'sets the correct title and classes' do
          html = helper.internal_comment_button(submission_evaluation)
          expect(html).to include('Internal Notes (1)')
          expect(html).to include('class="small button internal"')
        end
      end
    end

    describe 'feedback' do
      let(:submission_evaluation) { FactoryBot.create :submission_evaluation }
      context 'without comment' do
        it 'sets the correct title and classes' do
          html = helper.feedback_comment_button(submission_evaluation)

          expect(html).to include('Add Feedback')
          expect(html).to include('class="small button"')
        end
      end

      context 'with comment' do
        let!(:comment) { FactoryBot.create :feedback_comment, account: account, commentable: submission_evaluation }
        it 'sets the correct title and classes' do
          html = helper.feedback_comment_button(submission_evaluation)
          expect(html).to include('Feedback (1)')
          expect(html).to include('class="small button annotate"')
        end
      end
    end

    describe 'explanation' do
      let(:evaluation) { FactoryBot.create :fixed_evaluation }
      context 'without comment' do
        it 'sets the correct title and classes' do
          html = helper.evaluation_comment_button(evaluation)

          expect(html).to include('Explanations')
          expect(html).to include('class="tiny button expand secondary"')
        end
      end

      context 'with comment' do
        let!(:comment) { FactoryBot.create :explanations_comment, account: account, commentable: evaluation }
        it 'sets the correct title and classes' do
          html = helper.evaluation_comment_button(evaluation)
          expect(html).to include('Explanations (1)')
          expect(html).to include('class="tiny button expand annotate')
        end
      end
    end
  end

  describe 'string manipulation' do
    let(:evaluation) { FactoryBot.create :fixed_evaluation }
    let!(:explanations_comment) { FactoryBot.create :explanations_comment, account: account, commentable: evaluation }

    let(:submission_evaluation) { FactoryBot.create :submission_evaluation }
    let!(:feedback_comment) { FactoryBot.create :feedback_comment, account: account, commentable: submission_evaluation }

    it 'provides human readable comment names' do
      expect(helper.humanized_comment_type(explanations_comment)).to eq("Explanation")
      expect(helper.humanized_comment_type("Explanations")).to eq("Explanation")
    end

    it 'provides human readable comment headers' do
      expect(helper.comment_heading(explanations_comment)).to include("Explanation by <strong>")
      expect(helper.comment_heading(feedback_comment)).to include("Feedback from <strong>")

    end
  end
end
