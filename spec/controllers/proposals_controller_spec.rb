RSpec.describe(ProposalsController) do
  let(:proposer) { create(:user) }
  let(:proposee) { create(:user) }

  describe '#create' do
    subject(:post_create) do
      post(:create, params: { spouse_email: proposee_email })
    end

    let(:proposee_email) { proposee.email.upcase }
    let(:delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    before do
      sign_in(proposer)
      allow(ProposalMailer).to receive(:proposal_created).and_return(delivery)
    end

    it 'creates a normalized, recipient-bound proposal and sends it' do
      expect {
        post_create
      }.to change {
        proposer.sent_proposals.count
      }.by(1)

      proposal = proposer.sent_proposals.last!
      expect(proposal.proposee_email).to eq(proposee.email)
      expect(ProposalMailer).to have_received(:proposal_created).with(proposal.id)
      expect(flash[:notice]).to eq('Invitation sent.')
      expect(response).to redirect_to(check_ins_path)
    end

    context 'when the same proposal is already pending' do
      let!(:existing_proposal) do
        create(:proposal, proposer:, proposee_email: proposee.email)
      end

      it 'resends the existing proposal instead of creating another one' do
        expect {
          post_create
        }.not_to change {
          proposer.sent_proposals.count
        }

        expect(ProposalMailer).to have_received(:proposal_created).with(existing_proposal.id)
        expect(flash[:notice]).to eq('Invitation sent.')
      end
    end

    context 'when the email address is invalid' do
      let(:proposee_email) { 'not-an-email-address' }

      it 'does not persist or send a proposal' do
        expect {
          post_create
        }.not_to change {
          Proposal.count
        }

        expect(ProposalMailer).not_to have_received(:proposal_created)
        expect(flash[:alert]).to eq('Proposee email is invalid')
      end
    end

    context 'when the proposer already has a spouse' do
      before { create(:marriage, partners: [proposer, create(:user)]) }

      it 'does not create or send a proposal' do
        expect {
          post_create
        }.not_to change {
          Proposal.count
        }

        expect(ProposalMailer).not_to have_received(:proposal_created)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end
  end

  describe '#confirm' do
    subject(:get_confirm) do
      get(:confirm, params: { public_id: proposal.public_id })
    end

    let!(:proposal) { create(:proposal, proposer:, proposee_email: proposee.email) }
    let(:existing_marriage_warning) do
      'Warning: Accepting this proposal will delete your existing marriage and its associated ' \
        'check-in data.'
    end

    context 'when the intended proposee is signed in' do
      before { sign_in(proposee) }

      it 'renders a read-only confirmation page' do
        expect {
          get_confirm
        }.not_to change {
          proposal.reload.accepted_at
        }

        expect(response).to have_http_status(:ok)
        expect(response.body).to have_text(proposer.email)
        expect(response.body).to have_button('Accept proposal')
      end

      context 'when the proposee does not have an existing marriage' do
        before { expect(proposee.marriage).to be_nil }

        it 'does not show the existing marriage warning' do
          get_confirm

          expect(response.body).not_to have_text(existing_marriage_warning)
        end
      end

      context 'when the proposee has a solo marriage' do
        before { create(:marriage, partners: [proposee]) }

        it 'does not show the existing marriage warning' do
          get_confirm

          expect(response.body).not_to have_text(existing_marriage_warning)
        end
      end

      context 'when accepting would replace an existing partnered marriage' do
        before { create(:marriage, partners: [proposee, create(:user)]) }

        it 'warns that the existing marriage data will be deleted' do
          get_confirm

          expect(response.body).to have_text(existing_marriage_warning)
        end
      end

      context 'when the proposal has already been accepted' do
        before { proposal.update!(accepted_at: 1.minute.ago) }

        it 'shows that the proposal was accepted without an acceptance button' do
          get_confirm

          expect(response.body).to have_text('This proposal has already been accepted.')
          expect(response.body).not_to have_button('Accept proposal')
        end
      end
    end

    context 'when a different user is signed in' do
      before { sign_in(create(:user)) }

      it 'does not disclose the proposal' do
        get_confirm

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when the proposee is not signed in' do
      it 'redirects to sign in while preserving the identifier in the return path' do
        get_confirm

        expect(response).to redirect_to(new_user_session_path)
        expect(session['user_return_to']).to eq(confirm_proposal_path(proposal))
      end
    end
  end

  describe '#accept' do
    subject(:post_accept) do
      post(:accept, params: { public_id: proposal.public_id })
    end

    let!(:proposal) { create(:proposal, proposer:, proposee_email: proposee.email) }
    let!(:proposer_marriage) { create(:marriage, partners: [proposer]) }

    context 'when the intended proposee is signed in' do
      before { sign_in(proposee) }

      it 'accepts the proposal via POST' do
        expect {
          post_accept
        }.to change {
          proposal.reload.accepted_at
        }.from(nil)

        expect(proposer_marriage.reload.partners).to contain_exactly(proposer, proposee)
        expect(flash[:notice]).to eq('Marriage created.')
        expect(response).to redirect_to(check_ins_path)
      end

      context "when the proposer's marriage is already full" do
        before { proposer_marriage.partners << create(:user) }

        it 'reports the validation failure without accepting the proposal' do
          post_accept

          expect(proposal.reload.accepted_at).to be_nil
          expect(flash[:alert]).
            to eq("#{proposer.email}'s marriage already has two partners.")
          expect(response).to redirect_to(check_ins_path)
        end
      end
    end

    context 'when a different user is signed in' do
      before { sign_in(create(:user)) }

      it 'does not accept the proposal' do
        expect {
          post_accept
        }.not_to change {
          proposal.reload.accepted_at
        }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end
  end
end
