RSpec.describe Api::ReificationsController, :paper_trail do
  describe '#create' do
    subject(:post_create) { post(:create, params: { paper_trail_version_id: }) }

    context 'when paper_trail_version_id is that of a destroyed version' do
      let(:paper_trail_version_id) { item.versions.destroys.last!.id }
      let(:item) { Item.first! }

      before { item.destroy! }

      context 'when logged in as the user who owns the destroyed record' do
        before { sign_in(item.user) }

        it 'restores the destroyed PaperTrail version as the model record' do
          post_create

          expect { item.reload }.not_to raise_error
        end
      end

      context 'when logged in as a user who does not own the destroyed record' do
        before { sign_in(User.excluding(item.user).first!) }

        it 'does not restore the record' do
          post_create

          expect { item.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
