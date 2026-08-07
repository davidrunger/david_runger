RSpec.describe QuizParticipation do
  subject(:participation) do
    build(
      :quiz_participation,
      display_name: "Participant-#{SecureRandom.alphanumeric(5)}",
      participant: create(:user),
      quiz:,
    )
  end

  let(:quiz) { create(:quiz, owner: create(:user), status:) }

  context 'when the quiz has not started' do
    let(:status) { 'unstarted' }

    it { is_expected.to be_valid }
  end

  context 'when the quiz is active' do
    let(:status) { 'active' }

    it 'does not allow a new participation' do
      expect(participation).not_to be_valid
      expect(participation.errors[:quiz]).to include('has already started')
    end
  end

  context 'when the quiz is closed' do
    let(:status) { 'closed' }

    it 'does not allow a new participation' do
      expect(participation).not_to be_valid
    end
  end
end
