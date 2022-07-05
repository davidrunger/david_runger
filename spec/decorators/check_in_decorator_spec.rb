# frozen_string_literal: true

RSpec.describe CheckInDecorator do
  subject(:decorated_check_in) { check_in.decorate }

  let(:check_in) { CheckIn.joins(marriage: :emotional_needs).order('check_ins.created_at').first! }
  let(:marriage) { check_in.marriage }

  describe '#completed_by_both_partners?' do
    subject(:completed_by_both_partners?) { decorated_check_in.completed_by_both_partners? }

    context 'when the marriage has one emotional need' do
      before { expect(marriage.emotional_needs.size).to eq(1) }

      context "when one of the partners has not rated that need's satisfaction" do
        before { check_in.need_satisfaction_ratings.first.destroy! }

        it 'returns false' do
          expect(completed_by_both_partners?).to eq(false)
        end
      end

      context 'when both partners have rated the satisfaction of that need' do
        before do
          expect(
            check_in.
              need_satisfaction_ratings.
              where(user: marriage.partner_1).
              where.not(score: nil).
              size,
          ).to eq(1)

          expect(
            check_in.
              need_satisfaction_ratings.
              where(user: marriage.partner_2).
              where.not(score: nil).
              size,
          ).to eq(1)
        end

        it 'returns true' do
          expect(completed_by_both_partners?).to eq(true)
        end

        context 'when another need is added after the check-in was created' do
          before do
            emotional_need = create(:emotional_need, marriage:)
            expect(emotional_need.created_at).to be > check_in.created_at
          end

          it 'still returns true' do
            expect(completed_by_both_partners?).to eq(true)
          end
        end
      end
    end
  end

  describe '#completed_by_partner?' do
    subject(:completed_by_partner?) { decorated_check_in.completed_by_partner? }

    let(:current_user) { marriage.partner_1 }
    let(:spouse) { marriage.partner_2 }

    before { sign_in(current_user) }

    context 'when the marriage has one emotional need' do
      before { expect(marriage.emotional_needs.size).to eq(1) }

      context "when the other partner has not rated that need's satisfaction" do
        before do
          check_in.
            need_satisfaction_ratings.
            joins(:emotional_need).
            where(user: spouse).
            where('emotional_needs.created_at <= ?', check_in.created_at).
            first!.
            destroy!
        end

        it 'returns false' do
          expect(completed_by_partner?).to eq(false)
        end
      end

      context 'when the other partner has rated the satisfaction of that need' do
        before do
          expect(
            check_in.
              need_satisfaction_ratings.
              where(user: spouse).
              where.not(score: nil).
              size,
          ).to eq(1)
        end

        it 'returns true' do
          expect(completed_by_partner?).to eq(true)
        end

        context 'when another need is added after the check-in was created' do
          before do
            emotional_need = create(:emotional_need, marriage:)
            expect(emotional_need.created_at).to be > check_in.created_at
          end

          it 'still returns true' do
            expect(completed_by_partner?).to eq(true)
          end
        end
      end
    end
  end
end
