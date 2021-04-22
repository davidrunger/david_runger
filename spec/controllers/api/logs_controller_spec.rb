# frozen_string_literal: true

RSpec.describe Api::LogsController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#create' do
    subject(:post_create) { post(:create, params: params) }

    context 'when the log being created is valid' do
      let(:valid_params) do
        {
          log: {
            name: 'Resting Heart Rate',
            data_label: 'Heart Rate',
            data_type: 'number',
          },
        }
      end
      let(:params) { valid_params }

      it 'returns a 201 status code' do
        post_create
        expect(response.status).to eq(201)
      end

      it 'responds with the log as JSON' do
        post_create
        expect(response.parsed_body).to include(
          'data_label' => 'Heart Rate',
          'data_type' => 'number',
          'description' => nil,
          'id' => Integer,
          'name' => 'Resting Heart Rate',
          'publicly_viewable' => false,
          'slug' => 'resting-heart-rate',
        )
      end
    end

    context 'when the log being created is invalid' do
      let(:invalid_params) { { log: { name: '' } } }
      let(:params) { invalid_params }

      it 'logs info about the log and why it is invalid' do
        allow(Rails.logger).to receive(:info).and_call_original

        post_create

        expect(Rails.logger).to have_received(:info) do |logged_string|
          break if logged_string.include?('method=POST path=/api/logs')

          expect(logged_string).to match(/Failed to create log\./)
          expect(logged_string).to match(/errors={.*:name=>\["can't be blank"\].*}/)
          expect(logged_string).to match(/attributes={.*"name"=>"".*}/)
        end
      end

      it 'returns a 422 status code' do
        post_create
        expect(response.status).to eq(422)
      end
    end
  end

  describe '#update' do
    subject(:patch_update) { patch(:update, params: params) }

    context 'when a log has `publicly_viewable: false`' do
      before { expect(log.publicly_viewable?).to eq(false) }

      let(:log) { logs(:number_log) }

      context 'when the params have `publicly_viewable: true`' do
        let(:params) { { id: log.id, log: { publicly_viewable: true } } }

        it 'changes the log to `publicly_viewable: true`' do
          expect { patch_update }.to change { log.reload.publicly_viewable }.from(false).to(true)
        end

        it 'responds with the log as JSON' do
          patch_update
          expect(response.parsed_body).to include(
            'data_label' => log.data_label,
            'data_type' => 'number',
            'description' => log.description,
            'id' => Integer,
            'name' => log.name,
            'publicly_viewable' => log.reload.publicly_viewable,
            'slug' => log.slug,
          )
        end
      end
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete(:destroy, params: { id: log.id }) }

    let(:log) { logs(:number_log) }

    context 'when attempting to destroy the log of another user' do
      let(:owning_user) { log.user }
      let(:user) { User.where.not(id: owning_user).first! }

      it 'does not destroy the log' do
        expect { delete_destroy }.not_to change { log.reload.persisted? }
      end

      it 'returns a 404 status code' do
        delete_destroy
        expect(response.status).to eq(404)
      end
    end

    context "when attempting to destroy one's own log" do
      let(:user) { log.user }

      it 'destroys the log' do
        expect { delete_destroy }.to change { Log.find_by(id: log.id) }.from(Log).to(nil)
      end

      it 'returns a 204 status code' do
        delete_destroy
        expect(response.status).to eq(204)
      end
    end
  end
end
