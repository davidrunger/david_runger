RSpec.describe SidekiqExt::JobArgumentsFormatter do
  subject(:formatted_arguments) { described_class.new.call(arguments) }

  context 'with whitespace-free strings' do
    let(:arguments) { ['record-123', 'https://example.com/a-long-url'] }

    it 'preserves them' do
      expect(formatted_arguments).to eq('["record-123","https://example.com/a-long-url"]')
    end
  end

  context 'with strings containing whitespace' do
    let(:arguments) { ['first last', "tab\tvalue", "line\nbreak", "caf\u00e9 note"] }
    let(:expected_arguments) do
      '["[FILTERED: 10 bytes]","[FILTERED: 9 bytes]","[FILTERED: 10 bytes]",' \
        '"[FILTERED: 10 bytes]"]'
    end

    it 'filters each string using its original byte count' do
      expect(formatted_arguments).to eq(expected_arguments)
    end
  end

  context 'with nested arrays and hashes' do
    let(:arguments) do
      [
        {
          'preserved key' => ['private value', { 'nested' => "private\tnote" }],
          'number' => 1,
          'boolean' => true,
          'nothing' => nil,
        },
      ]
    end
    let(:expected_arguments) do
      '[{"preserved key":["[FILTERED: 13 bytes]",{"nested":"[FILTERED: 12 bytes]"}],' \
        '"number":1,"boolean":true,"nothing":null}]'
    end

    it 'filters string values while preserving hash keys and non-string values' do
      expect(formatted_arguments).to eq(expected_arguments)
    end
  end

  context 'with lengthy arguments' do
    let(:arguments) { [('123.' * 300).remove(/\.\z/)] }

    it 'truncates the final JSON output' do
      expect(formatted_arguments).to eq("[\"#{'123.' * 34}12...]")
    end
  end
end
