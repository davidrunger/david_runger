class SaveRequest::SkipChecker
  def initialize(params:)
    @controller = params['controller'].presence!
    @action = params['action'].presence!
    @params = params.presence!
  end

  def skip?
    case [@controller, @action, @params.symbolize_keys]
    in (
      ['health_checks', _, _] |
      ['anonymous', _, _] |
      ['blog', 'assets', _] |
      [_, _, { uptime_robot: _ }]
    )
      true
    else
      false
    end
  end
end
