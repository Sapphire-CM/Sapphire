require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'db columns' do
    it { is_expected.to have_db_column(:commentable_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:commentable_type).of_type(:string).with_options(null: false ) }
    it { is_expected.to have_db_column(:account_id).of_type(:integer).with_options(null: false ) }
    it { is_expected.to have_db_column(:term_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:content).of_type(:text).with_options(null: false) }

    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

end
