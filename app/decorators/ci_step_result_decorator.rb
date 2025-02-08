class CiStepResultDecorator < Draper::Decorator
  delegate_all

  def name_with_identifiers
    "#{object.name} (Run #{object.github_run_id}, Attempt #{object.github_run_attempt})"
  end
end
