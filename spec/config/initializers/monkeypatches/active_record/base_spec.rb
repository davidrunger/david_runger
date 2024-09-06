RSpec.describe(ActiveRecord::Base) do
  describe '::connection' do
    subject(:connection) { ActiveRecord::Base.connection }

    it 'raises an error' do
      expect { connection }.to raise_error(ActiveRecord::ActiveRecordError)
    end
  end
end
