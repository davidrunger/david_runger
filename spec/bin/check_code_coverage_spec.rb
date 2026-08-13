require 'open3'
require 'tempfile'

# rubocop:disable RSpec/DescribeClass
require 'spec_helper'

RSpec.describe 'bin/check-code-coverage' do
  # rubocop:enable RSpec/DescribeClass
  def run_check_code_coverage(coverage_xml)
    Tempfile.create('coverage.xml') do |coverage_report|
      coverage_report.write(coverage_xml)
      coverage_report.flush

      Open3.capture3(
        RbConfig.ruby,
        Rails.root.join('bin/check-code-coverage').to_s,
        coverage_report.path,
      )
    end
  end

  context 'when every valid line is covered' do
    let(:coverage_xml) do
      <<~XML
        <coverage lines-covered="3" lines-valid="3">
          <packages/>
        </coverage>
      XML
    end

    it 'reports 100% line coverage' do
      stdout, stderr, status = run_check_code_coverage(coverage_xml)

      expect(stdout).to eq("Line coverage is 100% (3/3 lines covered).\n")
      expect(stderr).to be_empty
      expect(status).to be_success
    end
  end

  context 'when valid lines are uncovered' do
    let(:coverage_xml) do
      <<~XML
        <coverage lines-covered="4" lines-valid="7">
          <packages>
            <package>
              <classes>
                <class filename="app/poros/first_example.rb">
                  <lines>
                    <line number="2" hits="0"/>
                    <line number="5" hits="1"/>
                    <line number="8" hits="0"/>
                  </lines>
                </class>
                <class filename="app/poros/second_example.rb">
                  <lines>
                    <line number="4" hits="0"/>
                  </lines>
                </class>
              </classes>
            </package>
          </packages>
        </coverage>
      XML
    end

    it 'reports every uncovered line before failing' do
      stdout, stderr, status = run_check_code_coverage(coverage_xml)

      expect(stdout).to be_empty
      expect(stderr).to eq(<<~OUTPUT)
        app/poros/first_example.rb:2
        app/poros/first_example.rb:8
        app/poros/second_example.rb:4
        Line coverage is not 100% (4/7 lines covered).
      OUTPUT
      expect(status).not_to be_success
    end
  end
end
