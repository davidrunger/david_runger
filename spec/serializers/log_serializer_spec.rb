# == Schema Information
#
# Table name: logs
#
#  created_at               :datetime         not null
#  data_label               :string           not null
#  data_type                :string           not null
#  description              :string
#  id                       :bigint           not null, primary key
#  name                     :string           not null
#  publicly_viewable        :boolean          default(FALSE), not null
#  reminder_last_sent_at    :datetime
#  reminder_time_in_seconds :integer
#  slug                     :string           not null
#  updated_at               :datetime         not null
#  user_id                  :bigint           not null
#
# Indexes
#
#  index_logs_on_user_id_and_name  (user_id,name) UNIQUE
#  index_logs_on_user_id_and_slug  (user_id,slug) UNIQUE
#
RSpec.describe(LogSerializer) do
  subject(:log_serializer) do
    LogSerializer.new(logs, params: { current_user: })
  end

  describe '#as_json' do
    subject(:as_json) { log_serializer.as_json }

    context 'when only one log is serialized' do
      subject(:log_as_json) { log_serializer.as_json.first }

      let(:log) { Log.first! }
      let(:logs) { Log.where(id: log) }

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
              expect(log_as_json).to have_key(field)
            end
          end
        end

        context 'when the log does not belong to the current user' do
          let(:current_user) { User.where.not(id: log.user).first! }

          it 'does not include private fields' do
            private_fields.each do |field|
              expect(log_as_json).not_to have_key(field.to_s)
            end
          end
        end
      end
    end
  end
end
