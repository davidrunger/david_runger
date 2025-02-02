RSpec.describe(StackTraceFilter) do
  subject(:stack_trace_filter) { StackTraceFilter.new }

  describe '#application_stack_trace' do
    subject(:application_stack_trace) { stack_trace_filter.application_stack_trace }

    context 'when the caller has Dockerized file paths' do
      before do
        expect(stack_trace_filter).to receive(:caller).and_return(mocked_stack_trace)
      end

      let(:mocked_stack_trace) do
        # rubocop:disable Layout/LineLength
        [
          "/app/app/models/event.rb:37:in 'Event.create_with_stack_trace!'",
          expected_line_of_interest,
          "/app/vendor/bundle/ruby/3.4.0/gems/actionpack-8.0.1/lib/action_controller/metal/basic_implicit_render.rb:8:in 'ActionController::BasicImplicitRender#send_action'",
          "/app/lib/middleware/early.rb:11:in 'Middleware::Early#call'",
        ]
        # rubocop:enable Layout/LineLength
      end
      let(:expected_line_of_interest) do
        "/app/app/controllers/api/events_controller.rb:11:in 'Api::EventsController#create'"
      end

      it 'returns only the lines of application code (and not the filter itself)' do
        expect(application_stack_trace).to eq([expected_line_of_interest])
      end
    end
  end
end
