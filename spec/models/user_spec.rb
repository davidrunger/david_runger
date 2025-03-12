RSpec.describe User do
  subject(:user) { users(:user) }

  it { is_expected.to have_many(:items) }
  it { is_expected.to have_many(:logs) }
  it { is_expected.to have_many(:log_shares) }

  describe '#emoji_boosts' do
    subject(:emoji_boosts) { user.emoji_boosts }

    context 'when the user has an emoji_boosts JsonPreference' do
      before { expect(emoji_boosts).to be_present }

      it 'returns an EMOJI_BOOSTS JsonPreference' do
        expect(emoji_boosts).to be_a(JsonPreference)
        expect(emoji_boosts.preference_type).to eq(JsonPreference::Types::EMOJI_BOOSTS)
      end
    end

    context 'when the user does not have emoji_boosts JsonPreference' do
      before { user.emoji_boosts&.destroy! && user.reload }

      it 'returns nil' do
        expect(emoji_boosts).to eq(nil)
      end
    end
  end

  describe '#marriage' do
    it 'returns a Marriage' do
      expect(user.marriage).to be_a(Marriage)
    end
  end

  describe '#spouse' do
    subject(:spouse) { user.spouse }

    context 'when the user is married' do
      it "returns the user's spouse" do
        expect(spouse).to eq(users(:married_user))
      end
    end

    context 'when the user is not married' do
      before do
        user.marriage&.destroy!
        user.reload
      end

      it 'returns nil' do
        expect(spouse).to eq(nil)
      end
    end
  end

  describe '#destroy' do
    subject(:destroy) { user.destroy }

    let(:user) do
      User.
        includes(
          :quizzes,
          logs: %i[log_shares log_entries],
          quiz_participations: :quiz_question_answer_selections,
          stores: :items,
        ).
        find(users(:user).id)
    end
    let!(:user_id) { user.id }

    context 'when the user has a marriage' do
      let!(:marriage_id) { user.marriage.id }

      it 'destroys the user and their marriage' do
        destroy # rubocop:disable Rails/SaveBang

        expect { User.find(user_id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { Marriage.find(marriage_id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the user does not have a marriage' do
      before { user.marriage&.destroy! }

      it 'destroys the user' do
        destroy # rubocop:disable Rails/SaveBang

        expect { User.find(user_id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#display_name' do
    subject(:display_name) { user.display_name }

    before { user.update!(email: "#{email_prefix}@gmail.com") }

    let(:email_prefix) { 'tom.talbot' }

    it 'returns the part of the email before "@"' do
      expect(display_name).to eq(email_prefix)
    end
  end
end
