# == Schema Information
#
# Table name: stores
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  name       :string           not null
#  notes      :text
#  private    :boolean          default(FALSE), not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#  viewed_at  :datetime         not null
#
# Indexes
#
#  index_stores_on_user_id_and_name  (user_id,name) UNIQUE
#
RSpec.describe(StoreSerializer) do
  subject(:store_serializer) do
    StoreSerializer.new(store, params: { current_user: })
  end

  let(:store) { users(:user).stores.first! }

  describe 'own_store attribute' do
    subject(:own_store) { store_serializer.as_json['own_store'] }

    context 'when the store belongs to the current user' do
      let(:current_user) { store.user }

      it 'returns true' do
        expect(own_store).to eq(true)
      end
    end
  end

  describe 'viewed_at attribute' do
    subject(:viewed_at) { store_serializer.as_json['viewed_at'] }

    context 'when the store belongs to the current user' do
      let(:current_user) { store.user }
      let(:viewed_at_time) { 3.days.ago }

      before { store.update!(viewed_at: viewed_at_time) }

      it 'is a timestamp formatted as JavaScript formats timestamps' do
        expect(viewed_at).to be_instance_of(String)
        expect(viewed_at).to eq(viewed_at_time.utc.iso8601(3))
      end
    end

    context "when the store belongs to the user's spouse" do
      let(:current_user) { store.user.spouse }

      it 'is nil' do
        expect(viewed_at).to eq(nil)
      end
    end
  end
end
