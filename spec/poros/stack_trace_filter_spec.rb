RSpec.describe(StackTraceFilter) do
  subject(:stack_trace_filter) { StackTraceFilter.new }

  describe '#application_stack_trace' do
    subject(:application_stack_trace) do
      stack_trace_filter.application_stack_trace(ignore: [file_to_ignore])
    end

    context 'when the caller has Dockerized file paths' do
      before do
        expect(stack_trace_filter).to receive(:caller).and_return(mocked_stack_trace)
      end

      let(:mocked_stack_trace) do
        # rubocop:disable Layout/LineLength
        [
          "#{file_to_ignore}:37:in 'Event.create_with_stack_trace!'",
          expected_line_of_interest,
          "/app/vendor/bundle/ruby/3.4.0/gems/actionpack-8.0.1/lib/action_controller/metal/basic_implicit_render.rb:8:in 'ActionController::BasicImplicitRender#send_action'",
          "/app/lib/middleware/early.rb:11:in 'Middleware::Early#call'",
        ]
        # rubocop:enable Layout/LineLength
      end
      let(:file_to_ignore) { '/app/app/models/event.rb' }
      let(:expected_line_of_interest) do
        "/app/app/controllers/api/events_controller.rb:11:in 'Api::EventsController#create'"
      end

      it 'returns only unignored lines of application code' do
        expect(application_stack_trace).to eq([expected_line_of_interest])
      end
    end
  end
end
