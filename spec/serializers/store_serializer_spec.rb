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

  let(:store) do
    Store.includes(
      { items: :item_availabilities },
      store_section_configurations: [
        { store_section_scheme: :store_sections },
        { item_section_assignments: :item_availability },
      ],
    ).find(stores(:store).id)
  end

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

  describe 'section attributes' do
    let(:current_user) { store.user }

    it 'serializes the current user\'s configuration and assignments' do
      expect(store_serializer.as_json).to include(
        'section_configuration' => {
          'sectioning_enabled' => true,
          'store_section_scheme' => {
            'id' => store_section_schemes(:grocery_layout).id,
            'name' => 'Grocery layout',
            'store_sections' => [
              { 'id' => store_sections(:produce_section).id, 'name' => 'Produce' },
            ],
          },
        },
        'item_section_assignments' => [
          {
            'item_id' => items(:item).id,
            'store_section_id' => store_sections(:produce_section).id,
          },
        ],
      )
    end
  end
end
