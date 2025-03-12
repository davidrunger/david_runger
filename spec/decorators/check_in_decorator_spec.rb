RSpec.describe CheckInDecorator do
  subject(:decorated_check_in) { check_in.decorate }

  let(:check_in) { CheckIn.joins(marriage: :emotional_needs).order('check_ins.created_at').first! }
  let(:marriage) { check_in.marriage }

  describe '#submitted_by_partner?' do
    subject(:submitted_by_partner?) { decorated_check_in.submitted_by_partner? }

    let(:current_user) { marriage.partners.first! }
    let(:spouse) { current_user.spouse.presence! }

    before { sign_in(current_user) }

    context 'when the partner has submitted their check-in' do
      before { create(:check_in_submission, user: spouse, check_in:) }

      it 'returns true' do
        expect(submitted_by_partner?).to eq(true)
      end
    end

    context 'when the partner has not submitted their check-in' do
      before { CheckInSubmission.where(user: spouse, check_in:).find_each(&:destroy!) }

      it 'returns false' do
        expect(submitted_by_partner?).to eq(false)
      end
    end
  end
end
