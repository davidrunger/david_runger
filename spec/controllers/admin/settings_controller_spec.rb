# frozen_string_literal: true

RSpec.describe Admin::SettingsController do
  context 'when logged in as an AdminUser' do
    before { sign_in(admin_users(:admin_user)) }

    describe '#index' do
      subject(:get_index) { get(:index) }

      it 'responds with 200' do
        get_index
        expect(response.status).to eq(200)
      end
    end

    describe '#new' do
      subject(:get_new) { get(:new) }

      it 'responds with 200' do
        get_new
        expect(response.status).to eq(200)
      end
    end

    describe '#show' do
      subject(:get_show) { get(:show, params: { name: setting_name }) }

      context 'when there is a RedisConfig setting set' do
        before do
          RedisConfig.add(setting_name, :integer)
          RedisConfig.set(setting_name, 9_000)
        end

        let(:setting_name) { 'power_level' }

        it 'responds with 200' do
          get_show
          expect(response.status).to eq(200)
        end
      end
    end

    describe '#edit' do
      subject(:get_edit) { get(:edit, params: { name: setting_name }) }

      context 'when there is a RedisConfig setting set' do
        before do
          RedisConfig.add(setting_name, :integer)
          RedisConfig.set(setting_name, 9_000)
        end

        let(:setting_name) { 'power_level' }

        it 'responds with 200' do
          get_edit
          expect(response.status).to eq(200)
        end
      end
    end

    describe '#create' do
      subject(:post_create) do
        post(
          :create,
          params: {
            redis_config_setting: {
              name: setting_name,
              type: type,
              value: value,
            },
          },
        )
      end

      let(:setting_name) { 'power_level' }
      let(:type) { 'integer' }
      let(:value) { rand(1_000) }

      it 'adds the setting to RedisConfig' do
        expect { RedisConfig.get(setting_name) }.to raise_error(ArgumentError)
        post_create
        expect(RedisConfig.get(setting_name).value).to eq(value)
      end
    end

    describe '#update' do
      subject(:patch_update) do
        patch(
          :update,
          params: {
            redis_config_setting: {
              name: setting_name,
              type: type,
              value: new_value,
            },
          },
        )
      end

      before do
        RedisConfig.add(setting_name, type)
        RedisConfig.set(setting_name, value)
      end

      let(:setting_name) { 'power_level' }
      let(:type) { 'integer' }
      let(:value) { rand(10_000) }
      let(:new_value) { value + 1 }

      it 'updates the setting value' do
        expect {
          patch_update
        }.to change {
          RedisConfig.get(setting_name).value
        }.from(value).
          to(new_value)
      end
    end

    describe '#destroy' do
      subject(:delete_destroy) { delete(:destroy, params: { name: setting_name }) }

      before do
        RedisConfig.add(setting_name, type)
        RedisConfig.set(setting_name, value)
      end

      let(:setting_name) { 'power_level' }
      let(:type) { 'integer' }
      let(:value) { rand(10_000) }

      it 'deletes the setting' do
        expect {
          delete_destroy
        }.to change {
          RedisConfig.get(setting_name).value rescue nil
        }.from(value).
          to(nil)
      end
    end
  end
end
