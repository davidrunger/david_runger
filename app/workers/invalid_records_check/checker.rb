# frozen_string_literal: true

class InvalidRecordsCheck::Checker
  prepend ApplicationWorker

  def perform(klass_name)
    @klass_name = klass_name
    @model_klass = klass_name.constantize

    relation = @model_klass.includes(included_associations)
    number_of_invalid_records = relation.find_each.count { |record| !record.valid? }

    if number_of_invalid_records > 0
      InvalidRecordsMailer.invalid_records(klass_name, number_of_invalid_records).deliver_later
    end
  end

  private

  def included_associations
    non_optional_belongs_to_associations + extra_includes
  end

  def non_optional_belongs_to_associations
    @model_klass.
      reflect_on_all_associations(:belongs_to).
      reject { |association| association.options[:optional] }.
      map(&:name)
  end

  def extra_includes
    case @klass_name
    when 'QuizQuestionAnswerSelection' then [:question]
    else []
    end
  end
end
