# frozen_string_literal: true

RSpec.describe RedisConfig do
  describe '::add' do # rubocop:disable Style/IpAddresses
    subject(:add) { RedisConfig.add(key_name, type) }

    let(:key_name) { 'max_response_time' }
    let(:type) { 'integer' }

    it 'allows the setting to be accessed without error' do
      expect { RedisConfig.get(key_name) }.to raise_error(ArgumentError)
      add
      expect { RedisConfig.get(key_name) }.not_to raise_error
    end

    it 'includes the value in `::all`' do
      add
      expect(RedisConfig.all.map(&:name)).to include(key_name)
    end

    context 'when declaring a `type` that is not supported' do
      let(:type) { 'json' }

      it 'raises an ArgumentError' do
        expect { add }.to raise_error(ArgumentError)
      end
    end

    context 'when attempting to add a key that has already been added' do
      before { RedisConfig.add(key_name, type) }

      it 'raises an ArgumentError' do
        expect { add }.to raise_error(ArgumentError)
      end
    end
  end

  describe '::set' do
    subject(:set) { RedisConfig.set(key_name, value) }

    before { RedisConfig.add(key_name, type) }

    let(:key_name) { 'max_response_time' }
    let(:type) { 'integer' }
    let(:value) { '20' }

    context 'when setting a value that cannot be coerced to the specified type' do
      let(:value) { 'not an integer' }

      it 'raises an ArgumentError' do
        expect { set }.to raise_error(ArgumentError)
      end
    end

    context 'when the value is initially nil' do
      it 'changes the retrieved value to the newly set value' do
        expect { set }.
          to change { RedisConfig.get(key_name).value }.
          from(nil).
          to(Integer(value))
      end
    end

    context 'when the value is initially something else' do
      before { RedisConfig.set(key_name, initial_value) }

      let(:initial_value) { 10 }

      it 'changes the retrieved value to the newly set value' do
        expect { set }.
          to change { RedisConfig.get(key_name).value }.
          from(initial_value).
          to(Integer(value))
      end
    end
  end

  describe '::get' do
    subject(:get) { RedisConfig.get(key_name) }

    context 'when the key has been added already' do
      before { RedisConfig.add(key_name, type) }

      let(:key_name) { 'max_response_time' }
      let(:type) { 'integer' }

      context 'when the value has not been set yet' do
        it 'returns nil' do
          expect(get.value).to eq(nil)
        end

        context 'when called with a backup value' do
          subject(:get) { RedisConfig.get(key_name, backup_value) }

          let(:backup_value) { rand(100_000) }

          it 'returns the backup_value' do
            expect(get.value).to eq(backup_value)
          end
        end
      end

      context 'when the value has been set' do
        before { RedisConfig.set(key_name, value) }

        let(:value) { '81' }

        it 'returns the value' do
          expect(get.value).to eq(Integer(value))
        end
      end

      context 'when the value exists in Redis but not the memory store' do
        before do
          RedisConfig.set(key_name, value)
          # this simulates e.g. a value being set in a web server process and then a sidekiq worker
          # booting up (which will not have a `@values_map` instance variable yet)
          RedisConfig.instance_variable_set(:@values_map, nil)
        end

        let(:value) { '81' }

        it 'returns the value correctly typed' do
          expect(get.value).to eq(Integer(value))
        end
      end
    end
  end

  describe '::all' do
    # (We can't really use `subject(:all)` because `all` is an RSpec method.)

    context 'when two keys have been added' do
      before do
        RedisConfig.add(setting_name_1, 'integer')
        RedisConfig.add(setting_name_2, 'integer')
      end

      let(:setting_name_1) { 'min_response_time' }
      let(:setting_name_2) { 'max_response_time' }

      it 'returns an array of two RedisConfig::Setting instances' do
        expect(RedisConfig.all).to all(be_a(RedisConfig::Setting))
        expect(RedisConfig.all.map(&:name)).to eq([setting_name_1, setting_name_2])
      end
    end
  end

  describe '::delete' do
    subject(:delete) { RedisConfig.delete(key_name) }

    context 'when the key has been added already' do
      before { RedisConfig.add(key_name, type) }

      let(:key_name) { 'max_response_time' }
      let(:type) { 'integer' }

      it 'causes an exception to be raised when attempting to access the setting' do
        expect { RedisConfig.get(key_name) }.not_to raise_error
        delete
        expect { RedisConfig.get(key_name) }.to raise_error(ArgumentError)
      end
    end
  end
end
