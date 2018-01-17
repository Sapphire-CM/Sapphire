require 'rails_helper'

RSpec.describe SubmissionBulk::BulkNotValid do
  describe 'inheritance' do
    it { is_expected.to be_a(StandardError) }
  end
end