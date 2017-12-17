StatsD.backend = StatsD::Instrument::Backends::UDPBackend.new('localhost:8125', :statsd)
