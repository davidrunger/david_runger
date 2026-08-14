class RestoreBlazerQueryComparisonOperators < Datamigration::Base
  def run
    within_transaction do
      queries_with_escaped_comparison_operators.find_each do |query|
        query.update!(statement: restored_statement(query.statement))

        log("Restored comparison operators in Blazer::Query:#{query.id}.")
      end
    end
  end

  private

  def queries_with_escaped_comparison_operators
    Blazer::Query.where(
      'statement LIKE ? OR statement LIKE ?',
      '%&gt;%',
      '%&lt;%',
    )
  end

  def restored_statement(statement)
    statement.gsub('&gt;', '>').gsub('&lt;', '<')
  end
end

Datamigration::Runner.new(RestoreBlazerQueryComparisonOperators).run
