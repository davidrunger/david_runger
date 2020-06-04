# frozen_string_literal: true

RSpec.describe ApplicationController do
  controller do
    def index
      render(plain: 'This is the #index action.')
    end
  end

  describe '#enable_rack_mini_profiler_if_admin' do
    subject(:get_index) { get(:index) }

    context 'when a user is logged in' do
      before { sign_in(user) }

      context 'when `rack_mini_profiler_enabled` config is true' do
        before do
          expect(Rails.configuration).to receive(:rack_mini_profiler_enabled).and_return(true)
        end

        context 'when the logged in user is an admin' do
          before { expect(user.admin?).to eq(true) }

          let(:user) { users(:admin) }

          it 'calls `Rack::MiniProfiler.authorize_request`' do
            # load `Rack::MiniProfiler` since (in test) it won't have been loaded via
            # `config/initializers/`
            require 'rack-mini-profiler'
            expect(Rack::MiniProfiler).to receive(:authorize_request)

            get_index
          end
        end
      end
    end
  end
end
