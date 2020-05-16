# frozen_string_literal: true

RSpec.describe UserAgentField do
  subject(:field) { UserAgentField.new(:user_agent, raw_user_agent, page) }

  let(:raw_user_agent) { 'curl/7.54.0' }
  let(:page) { :index }

  specify { expect(field.class.ancestors).to include(Administrate::Field::Base) }

  describe '#summary_info' do
    subject(:summary_info) { field.summary_info }

    context 'when `browser` can identify the browser' do
      let(:raw_user_agent) do
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:70.0) Gecko/20100101 Firefox/70.0'
      end
      let(:parsed_browser_name) { 'Firefox' }

      before { expect(Browser.new(raw_user_agent).name).to eq(parsed_browser_name) }

      it 'returns info including the parsed browser name' do
        expect(summary_info).to match(/\A#{parsed_browser_name}/)
      end
    end

    context 'when `browser` cannot identify the browser' do
      let(:raw_user_agent) { 'curl/7.54.0' }

      before { expect(Browser.new(raw_user_agent).name).to eq('Generic Browser') }

      it 'returns the raw user agent' do
        expect(summary_info).to eq(raw_user_agent)
      end
    end
  end
end
