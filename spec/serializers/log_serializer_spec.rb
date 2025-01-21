RSpec.describe(LogSerializer) do
  subject(:log_serializer) do
    LogSerializer.new(log, params: { current_user: })
  end

  let(:log) { Log.first! }

  describe '#as_json' do
    subject(:as_json) { log_serializer.as_json }

    describe 'private fields' do
      let(:private_fields) do
        %w[
          publicly_viewable
          reminder_time_in_seconds
          log_shares
        ]
      end

      context 'when the log belongs to the current user' do
        let(:current_user) { log.user }

        it 'includes private fields' do
          private_fields.each do |field|
            expect(as_json).to have_key(field)
          end
        end
      end

      context 'when the log does not belong to the current user' do
        let(:current_user) { User.where.not(id: log.user).first! }

        it 'does not include private fields' do
          private_fields.each do |field|
            expect(as_json).not_to have_key(field.to_s)
            expect(as_json).not_to have_key(field.to_sym)
          end
        end
      end
    end
  end
end
