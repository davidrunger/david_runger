# == Schema Information
#
# Table name: users
#
#  created_at  :datetime         not null
#  email       :string           not null
#  google_sub  :string
#  id          :bigint           not null, primary key
#  public_name :string
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
RSpec.describe UserSerializer do
  let(:user) { users(:user) }

  describe UserSerializer::Public do
    subject(:user_serializer_public_as_json) do
      UserSerializer::Public.new(object_to_serialize).as_json
    end

    describe 'public_name attribute' do
      context 'when serializing a single user' do
        subject(:public_name) { user_serializer_public_as_json['public_name'] }

        let(:object_to_serialize) { user }

        context 'when the user has a public_name' do
          before { user.update!(public_name: 'David Runger') }

          it "is the user's public_name" do
            expect(public_name).to eq(user.public_name)
          end
        end

        context 'when the user does not have a public_name' do
          before { user.update!(public_name: nil) }

          it 'is nil' do
            expect(public_name).to eq(nil)
          end
        end
      end

      context 'when serializing multiple users' do
        subject(:public_names) { user_serializer_public_as_json.pluck('public_name') }

        let(:object_to_serialize) { User.reorder(:id).limit(2) }

        context 'when the users have public_names' do
          before { object_to_serialize.find_each { it.update!(public_name: 'David Runger') } }

          it "is the users' public_names" do
            expect(public_names).to eq(['David Runger'] * 2)
          end
        end

        context 'when the users do not have public_names' do
          before { user.update!(public_name: nil) }

          it "is 'nil' for each of the users" do
            expect(public_names).to eq([nil] * 2)
          end
        end
      end
    end
  end
end
