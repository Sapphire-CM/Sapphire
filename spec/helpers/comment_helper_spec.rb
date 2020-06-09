require 'rails_helper'

RSpec.describe CommentsHelper, type: :helper do
  describe 'evaluation comment button' do
    let(:account) { FactoryGirl.create(:account, :admin) }
    let(:evaluation) { FactoryGirl.create :fixed_evaluation }

    context 'without comment' do
      it 'sets the correct classes' do
        expect(helper.evaluation_comment_button(evaluation)).to include('class="tiny button expand secondary"')
      end
    end

    context 'with comment' do
      let!(:comment) { FactoryGirl.create :explanations_comment, account: account, commentable: evaluation }
      it 'sets the correct classes' do
        html = helper.evaluation_comment_button(evaluation)
        expect(html).to include('tiny button expand')
        expect(html).not_to include('secondary')
      end
    end
  end
end
