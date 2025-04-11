RSpec::Matchers.define(:match_schema) do |schema|
  schema_path = "spec/support/schemas/#{schema}.json"
  match do |json|
    JSONSchemer.schema(File.read(schema_path)).validate(JSON.parse(json)).to_a.empty?
  end

  failure_message do |json|
    "expected #{json} to match schema #{schema}"
  end
end
