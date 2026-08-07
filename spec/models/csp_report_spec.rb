RSpec.describe CspReport do
  describe 'validations' do
    it 'limits URI field lengths' do
      %i[blocked_uri document_uri referrer].each do |attribute|
        expect(build(:csp_report, attribute => 'a' * CspReport::MAX_URI_LENGTH)).to be_valid
        expect(
          build(:csp_report, attribute => 'a' * (CspReport::MAX_URI_LENGTH + 1)),
        ).not_to be_valid
      end
    end

    it 'limits other attacker-controlled field lengths' do
      {
        original_policy: CspReport::MAX_ORIGINAL_POLICY_LENGTH,
        user_agent: CspReport::MAX_USER_AGENT_LENGTH,
        violated_directive: CspReport::MAX_VIOLATED_DIRECTIVE_LENGTH,
      }.each do |attribute, maximum|
        expect(build(:csp_report, attribute => 'a' * maximum)).to be_valid
        expect(build(:csp_report, attribute => 'a' * (maximum + 1))).not_to be_valid
      end
    end
  end
end
