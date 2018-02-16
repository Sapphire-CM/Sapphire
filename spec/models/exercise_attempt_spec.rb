require 'rails_helper'

RSpec.describe ExerciseAttempt, type: :model do
  describe 'db columns' do
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:date).of_type(:datetime) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:exercise).inverse_of(:attempts) }
    it { is_expected.to have_many(:submissions).dependent(:nullify) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:exercise) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:title).scoped_to(:exercise_id) }
  end
end
