RSpec.describe ApplicationPolicy do
  subject(:policy) { ApplicationPolicy.new(user, workout) }

  let(:workout) { user&.workouts&.first! }
  let(:user) { users(:user) }

  # rubocop:disable RSpec/EmptyLineAfterSubject
  describe '#index?' do
    subject(:index?) { policy.index? }

    context 'when there is a user' do
      let(:user) { users(:user) }

      specify { expect(index?).to eq(true) }
    end

    context 'when there is no user' do
      let(:user) { nil }

      specify { expect(index?).to eq(false) }
    end
  end

  describe '#show?' do
    subject(:show?) { policy.show? }
    specify { expect(show?).to eq(true) }
  end

  describe '#create?' do
    subject(:create?) { policy.create? }

    context 'when there is a user' do
      let(:user) { users(:user) }

      specify { expect(create?).to eq(true) }
    end

    context 'when there is no user' do
      let(:user) { nil }

      specify { expect(create?).to eq(false) }
    end
  end

  describe '#new?' do
    subject(:new?) { policy.new? }

    context 'when there is a user' do
      let(:user) { users(:user) }

      specify { expect(new?).to eq(true) }
    end

    context 'when there is no user' do
      let(:user) { nil }

      specify { expect(new?).to eq(false) }
    end
  end

  describe '#update?' do
    subject(:update?) { policy.update? }
    specify { expect(update?).to eq(true) }
  end

  describe '#edit?' do
    subject(:edit?) { policy.edit? }
    specify { expect(edit?).to eq(true) }
  end

  describe '#destroy?' do
    subject(:destroy?) { policy.destroy? }
    specify { expect(destroy?).to eq(true) }
  end
  # rubocop:enable RSpec/EmptyLineAfterSubject

  describe '#scope' do
    subject(:scope) { policy.scope }

    it 'returns the set of records that the user may access' do
      expect(scope.order(:id)).
        to eq(Workout.where(user:).or(Workout.where(publicly_viewable: true)).order(:id))
    end

    context 'when the policy does not define a scope' do
      subject(:policy) { ApplicationPolicy.new(user, user.logs.first!) } # there is no Log Scope

      it 'defaults to an empty relation' do
        expect(scope).to eq(Log.none)
      end
    end
  end
end
