# frozen_string_literal: true

RSpec.describe ApplicationPolicy do
  subject(:policy) { ApplicationPolicy.new(user, record) }

  let(:user) { users(:user) }
  let(:record) { users(:admin) }

  # rubocop:disable RSpec/EmptyLineAfterSubject
  describe '#index?' do
    subject(:index?) { policy.index? }
    specify { expect(index?).to eq(false) }
  end

  describe '#show?' do
    subject(:show?) { policy.show? }
    specify { expect(show?).to eq(false) }
  end

  describe '#create?' do
    subject(:create?) { policy.create? }
    specify { expect(create?).to eq(false) }
  end

  describe '#new?' do
    subject(:new?) { policy.new? }
    specify { expect(new?).to eq(false) }
  end

  describe '#update?' do
    subject(:update?) { policy.update? }
    specify { expect(update?).to eq(false) }
  end

  describe '#edit?' do
    subject(:edit?) { policy.edit? }
    specify { expect(edit?).to eq(false) }
  end

  describe '#destroy?' do
    subject(:destroy?) { policy.destroy? }
    specify { expect(destroy?).to eq(false) }
  end
  # rubocop:enable RSpec/EmptyLineAfterSubject

  describe '#scope' do
    subject(:scope) { policy.scope }

    it 'returns an empty set of records' do
      expect(scope).not_to exist
    end
  end
end
