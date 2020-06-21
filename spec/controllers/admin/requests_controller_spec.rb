# frozen_string_literal: true

RSpec.describe Admin::RequestsController do
  before { sign_in(admin_user) }

  let(:admin_user) { users(:admin) }
  # `request` is sort of a "reserved word" in tests, I think, so call it `first_request`
  let(:first_request) { Request.order(:requested_at).first! }

  describe '#index' do
    subject(:get_index) { get(:index, params: params) }

    context 'when viewing the requests sorted in ascending order of requested_at' do
      let(:params) { { 'request[order]' => 'requested_at', 'request[direction]' => 'asc' } }

      context 'when the request is associated with an auth token' do
        before { first_request.update!(auth_token: AuthToken.first!) }

        it 'shows the expected info about the Request' do
          get_index

          # There are some other fields, but these are the simplest ones to check
          expect(response.body).to have_text(first_request.id)
          expect(response.body).to have_text(first_request.handler)
          expect(response.body).to have_text(first_request.location)
          expect(response.body).to have_text(first_request.isp)
          expect(response.body).to have_text(first_request.ip)
        end
      end
    end
  end

  describe '#show' do
    subject(:get_show) { get(:show, params: { id: first_request.id }) }

    it 'shows the expected info about the Request' do
      get_show

      # There are some other fields, but these are the simplest ones to check
      expect(response.body).to have_text(first_request.id)
      expect(response.body).to have_text(first_request.handler)
      expect(response.body).to have_text(first_request.location)
      expect(response.body).to have_text(first_request.isp)
      expect(response.body).to have_text(first_request.ip)
      expect(response.body).to have_text(first_request.request_id)
    end
  end
end
