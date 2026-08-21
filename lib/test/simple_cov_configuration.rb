unless defined?(Test)
  module Test ; end
end

module Test::SimpleCovConfiguration
  def self.configure
    SimpleCov.skip(%r{^tools/(?!custom_cops/)})
  end
end
