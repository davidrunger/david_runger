# frozen_string_literal: true

RSpec.describe Log do
  subject(:log) { logs(:number_log) }

  it { is_expected.to have_many(:log_shares) }

  describe '::needing_reminder' do
    subject(:needing_reminder) { Log.needing_reminder }

    context 'when the log does not have a reminder_time_in_seconds value' do
      before { log.update!(reminder_time_in_seconds: nil) }

      it 'does not include the log' do
        expect(needing_reminder).not_to include(log)
      end
    end

    context 'when the log has a reminder_time_in_seconds value' do
      before { log.update!(reminder_time_in_seconds: Integer(reminder_time_interval)) }

      let(:reminder_time_interval) { 3.days }

      context 'when the log has at least one log entry' do
        let(:log) { Log.joins(:text_log_entries).first! }

        context 'when all log entries were created long enough ago that a reminder is needed' do
          before do
            log.log_entries.find_each do |log_entry|
              log_entry.update!(created_at: reminder_time_interval.ago - 1.minute)
            end
          end

          context 'when the log was created less than the reminder time interval ago' do
            before { log.update!(created_at: reminder_time_interval.ago + 1.minute) }

            it 'does not include the log' do
              expect(needing_reminder).not_to include(log)
            end
          end

          context 'when the log was created more than the reminder time interval ago' do
            before { log.update!(created_at: reminder_time_interval.ago - 1.hour) }

            context 'when a reminder email has never been sent' do
              before { log.update!(reminder_last_sent_at: nil) }

              it 'includes the log' do
                expect(needing_reminder).to include(log)
              end
            end

            context 'when last reminder was sent prior to the creation of the most recent entry' do
              before do
                last_log_entry_created_at = log.log_entries.order(:created_at).last!.created_at
                log.update!(reminder_last_sent_at: last_log_entry_created_at - 1.minute)
              end

              it 'includes the log' do
                expect(needing_reminder).to include(log)
              end
            end

            context 'when last reminder was sent after the creation of the most recent entry' do
              before do
                last_log_entry_created_at = log.log_entries.order(:created_at).last!.created_at
                log.update!(reminder_last_sent_at: last_log_entry_created_at + 1.minute)
              end

              it 'does not include the log' do
                expect(needing_reminder).not_to include(log)
              end
            end
          end
        end

        context 'when a log entry was created recently enough that a reminder is not needed' do
          before do
            log.log_entries.first!.update!(created_at: reminder_time_interval.ago + 1.minute)
          end

          it 'does not include the log' do
            expect(needing_reminder).not_to include(log)
          end
        end
      end

      context 'when the log has no log entries' do
        before { log.log_entries.find_each(&:destroy!) }

        context 'when the log was created long enough ago that a reminder is needed' do
          before { log.update!(created_at: reminder_time_interval.ago - 1.minute) }

          context 'when a reminder email has never been sent' do
            before { log.update!(reminder_last_sent_at: nil) }

            it 'includes the log' do
              expect(needing_reminder).to include(log)
            end
          end

          context 'when a reminder email has been sent' do
            before { log.update!(reminder_last_sent_at: log.created_at + 1.minute) }

            it 'does not include the log' do
              expect(needing_reminder).not_to include(log)
            end
          end
        end

        context 'when the log was created recently enough ago that a reminder is not yet needed' do
          before { log.update!(created_at: reminder_time_interval.ago + 1.minute) }

          it 'does not include the log' do
            expect(needing_reminder).not_to include(log)
          end
        end
      end
    end
  end
end
