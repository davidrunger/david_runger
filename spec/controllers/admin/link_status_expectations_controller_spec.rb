RSpec.describe Admin::LinkStatusExpectationsController do
  context 'when logged in as an AdminUser' do
    let(:admin_user) { admin_users(:admin_user) }
    let(:link_status_expectation) { link_status_expectations(:app_academy) }

    before { sign_in(admin_user) }

    describe '#update' do
      subject(:put_update) do
        put(
          :update,
          params: {
            id: link_status_expectation.id,
            link_status_expectation: { status: 302 },
          },
        )
      end

      it "records the AdminUser's class ID string as the PaperTrail whodunnit", :versioning do
        expect { put_update }.to change { link_status_expectation.versions.count }.by(1)

        expect(link_status_expectation.versions.last!.whodunnit).
          to eq(admin_user.class_id_string)
      end
    end

    describe '#destroy' do
      subject(:delete_destroy) do
        delete(:destroy, params: { id: link_status_expectation.id })
      end

      it "records the AdminUser's class ID string as the PaperTrail whodunnit", :versioning do
        expect { delete_destroy }.to change { link_status_expectation.versions.count }.by(1)

        expect(link_status_expectation.versions.last!.whodunnit).
          to eq(admin_user.class_id_string)
      end
    end
  end
end
