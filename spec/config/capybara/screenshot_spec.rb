RSpec.describe Capybara::Screenshot do
  describe '.capybara_root' do
    it 'uses a dedicated failure screenshot path separate from browser downloads' do
      expect(described_class.capybara_root).
        to eq(Rails.root.join('tmp/failure_screenshots').to_s)
      expect(Capybara.save_path).not_to eq(described_class.capybara_root)
    end
  end
end
