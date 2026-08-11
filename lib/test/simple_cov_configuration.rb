module Test ; end unless defined?(Test)

module Test::SimpleCovConfiguration
  def self.configure
    SimpleCov.skip(%r{^tools/(?!custom_cops/)})
  end
end
