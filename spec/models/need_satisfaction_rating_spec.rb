# frozen_string_literal: true

RSpec.describe NeedSatisfactionRating do
  subject(:need_satisfaction_rating) { build(:need_satisfaction_rating) }

  describe 'validations' do
    context 'when the score is nil' do
      before { expect(need_satisfaction_rating.score).to be(nil) }

      it 'is valid' do
        expect(need_satisfaction_rating).to be_valid
      end
    end

    context 'when the score is between -3 and 3' do
      before { need_satisfaction_rating.score = 0 }

      it 'is valid' do
        expect(need_satisfaction_rating).to be_valid
      end
    end

    context 'when the score is less than -3' do
      before { need_satisfaction_rating.score = -4 }

      it 'is not valid' do
        expect(need_satisfaction_rating).not_to be_valid
      end
    end

    context 'when the score is grater than 3' do
      before { need_satisfaction_rating.score = 4 }

      it 'is not valid' do
        expect(need_satisfaction_rating).not_to be_valid
      end
    end
  end
end
