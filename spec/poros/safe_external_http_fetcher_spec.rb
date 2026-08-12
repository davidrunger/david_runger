RSpec.describe SafeExternalHttpFetcher do
  # rubocop:disable Style/IpAddresses
  subject(:fetcher) { described_class.new }

  describe '#get' do
    subject(:get) { fetcher.get(url, timeout: 5) }

    let(:url) { 'https://public.example.test/path?query=value' }
    let(:hostname) { 'public.example.test' }
    let(:resolved_addresses) { [] }

    before do
      allow(Resolv).to receive(:getaddresses).with(hostname).and_return(resolved_addresses)
      stub_request(:get, url).to_return(status: 200, body: '', headers: {})
    end

    context 'when the hostname resolves to a public IPv4 address' do
      let(:resolved_addresses) { ['8.8.8.8'] }

      it 'connects to the address' do
        expect(get.status).to eq(200)
      end

      it 'pins the connection while preserving the hostname for HTTP and TLS' do
        expect(Net::HTTP).to receive(:new).with(hostname, 443, nil).
          and_wrap_original do |method, *arguments|
            method.call(*arguments).tap do |http|
              expect(http).to receive(:ipaddr=).with('8.8.8.8').and_call_original
              expect(http).to receive(:open_timeout=).with(5).and_call_original
              expect(http).to receive(:read_timeout=).with(5).and_call_original
              expect(http.address).to eq(hostname)
            end
          end

        get
      end
    end

    context 'when the hostname resolves to a public IPv6 address' do
      let(:resolved_addresses) { ['2606:4700:4700::1111'] }

      it 'connects to the address' do
        expect(get.status).to eq(200)
      end
    end

    [
      '127.0.0.1',
      '::1',
      '10.0.0.1',
      'fd00::1',
      '169.254.169.254',
      'fe80::1',
      '0.0.0.0',
      '::',
      '224.0.0.1',
      '100.64.0.1',
      '192.0.2.1',
      '::ffff:127.0.0.1',
      '::ffff:10.0.0.1',
    ].each do |address|
      context "when the hostname resolves to prohibited address #{address}" do
        let(:resolved_addresses) { [address] }

        it 'raises an unsafe URL error without making a request' do
          expect { get }.to raise_error(described_class::UnsafeUrlError)
          expect(a_request(:get, url)).not_to have_been_made
        end
      end
    end

    context 'when the hostname resolves to public and prohibited addresses' do
      let(:resolved_addresses) { ['8.8.8.8', '127.0.0.1'] }

      it 'rejects the hostname without making a request' do
        expect { get }.to raise_error(described_class::UnsafeUrlError)
        expect(a_request(:get, url)).not_to have_been_made
      end
    end

    context 'when hostname resolution fails' do
      before do
        allow(Resolv).to receive(:getaddresses).with(hostname).
          and_raise(Resolv::ResolvError, 'DNS failure')
      end

      it 'raises an unsafe URL error without making a request' do
        expect { get }.to raise_error(described_class::UnsafeUrlError)
        expect(a_request(:get, url)).not_to have_been_made
      end
    end

    context 'when resolution returns an unsupported address family' do
      let(:resolved_addresses) { ['8.8.8.8'] }
      let(:unsupported_address) do
        instance_double(IPAddr, ipv4_mapped?: false, ipv4?: false, ipv6?: false)
      end

      before do
        allow(IPAddr).to receive(:new).with('8.8.8.8').and_return(unsupported_address)
      end

      it 'raises an unsafe URL error without making a request' do
        expect { get }.
          to raise_error(described_class::UnsafeUrlError, /Unsupported resolved address/)
        expect(a_request(:get, url)).not_to have_been_made
      end
    end

    [
      'not a URL',
      'ftp://public.example.test/',
      'https:///path',
      'https://user:password@public.example.test/',
    ].each do |unsafe_url|
      context "when the URL is #{unsafe_url.inspect}" do
        let(:url) { unsafe_url }

        it 'rejects it without resolving or making a request' do
          expect { get }.to raise_error(described_class::UnsafeUrlError)
          expect(Resolv).not_to have_received(:getaddresses)
          expect(a_request(:get, url)).not_to have_been_made
        end
      end
    end
  end
  # rubocop:enable Style/IpAddresses
end
