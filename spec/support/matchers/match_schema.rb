# frozen_string_literal: true

RSpec::Matchers.define(:match_schema) do |schema|
  match do |json|
    JSON::Validator.fully_validate(schema, json, strict: true, validate_schema: true).empty?
  end

  failure_message do |json|
    "expected #{json} to match schema #{schema}"
  end
end
