RSpec.describe(Event) do
  describe 'associations' do
    it { is_expected.to belong_to(:admin_user).optional }
    it { is_expected.to belong_to(:user).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:ip) }
    it { is_expected.to validate_presence_of(:stack_trace) }
    it { is_expected.to validate_presence_of(:type) }

    it 'limits attacker-controlled field lengths' do
      {
        type: Event::MAX_TYPE_LENGTH,
        user_agent: Event::MAX_USER_AGENT_LENGTH,
      }.each do |attribute, maximum|
        expect(build(:event, attribute => 'a' * maximum)).to be_valid
        expect(build(:event, attribute => 'a' * (maximum + 1))).not_to be_valid
      end
    end

    it 'limits the serialized data size in bytes' do
      data_at_limit = 'a' * (Event::MAX_DATA_BYTES - ''.to_json.bytesize)

      expect(data_at_limit.to_json.bytesize).to eq(Event::MAX_DATA_BYTES)
      expect(build(:event, data: data_at_limit)).to be_valid
      expect(build(:event, data: "#{data_at_limit}a")).not_to be_valid
    end
  end
end
