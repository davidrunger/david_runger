# frozen_string_literal: true

RSpec.describe ApplicationPolicy do
  subject(:policy) { ApplicationPolicy.new(user, log) }

  let(:log) { user.logs.first! }
  let(:user) { users(:user) }

  # rubocop:disable RSpec/EmptyLineAfterSubject
  describe '#index?' do
    subject(:index?) { policy.index? }
    specify { expect(index?).to eq(true) }
  end

  describe '#show?' do
    subject(:show?) { policy.show? }
    specify { expect(show?).to eq(true) }
  end

  describe '#create?' do
    subject(:create?) { policy.create? }
    specify { expect(create?).to eq(true) }
  end

  describe '#new?' do
    subject(:new?) { policy.new? }
    specify { expect(new?).to eq(true) }
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
      expect(scope.order(:id)).to eq(user.logs.order(:id))
    end
  end
end
