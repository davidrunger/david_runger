RSpec.describe EmailFormatValidator do
  subject(:validate) do
    described_class.new(attributes: [:email]).validate_each(user, :email, value)
  end

  let(:user) { User.new }

  context 'when the value is blank' do
    let(:value) { '' }

    it 'leaves blank-value errors to presence validation' do
      validate

      expect(user.errors.full_messages).to eq([])
    end
  end

  context 'when the value has an invalid format' do
    let(:value) { 'not-an-email-address' }

    it 'adds a full error message' do
      validate

      expect(user.errors.full_messages).to eq(['Email is invalid'])
    end
  end

  context 'when the value has a valid format' do
    let(:value) { 'spouse@example.com' }

    it 'does not add an error' do
      validate

      expect(user.errors.full_messages).to eq([])
    end
  end
end
