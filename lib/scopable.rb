# frozen_string_literal: true

# borrowed (with modification) from https://github.com/corenzan/scopable
class Scopable
  attr_reader :model, :scopes

  def initialize(model = nil, scopes = nil)
    @model = model || self.class.model
    @scopes = scopes || self.class.scopes
  end

  def delegator(relation, value, params)
    SimpleDelegator.new(relation).tap do |delegator|
      delegator.define_singleton_method(:value) do
        value
      end
      delegator.define_singleton_method(:params) do
        params
      end
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  def resolve(base_relation, params)
    params = params.with_indifferent_access

    scopes.reduce(base_relation) do |relation, scope|
      name, options = *scope

      # Resolve param name.
      param = options[:param] || name

      # Resolve a value for the scope.
      value = options[:value] || params[param] || options[:default]

      # When value is empty treat it as nil.
      value = nil if value.respond_to?(:empty?) && value.empty?

      # When a nil value was given either skip the scope or bail with #none (if the required options
      # was used).
      if value.nil?
        if options[:required]
          break relation.none
        else
          next relation
        end
      end

      # Cast boolean-like strings.
      case value.to_s
      when /\A(false|no|off)\z/
        value = false
      when /\A(true|yes|on)\z/
        value = true
      end

      # Enforce 'if' option.
      if options[:if]
        unless delegator(relation, value, params).instance_exec(&options[:if])
          next relation
        end
      end

      # Enforce 'unless' option.
      if options[:unless]
        if delegator(relation, value, params).instance_exec(&options[:unless])
          next relation
        end
      end

      # Bail if the value is false or nil.
      next relation unless value

      # When a block is present, use that, otherwise call the scope method.
      if options[:block].present?
        delegator(relation, value, params).instance_exec(&options[:block])
      elsif value == true
        relation.public_send(name)
      else
        relation.public_send(name, value)
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

  def self.resolve(base_relation, params)
    new.resolve(base_relation, params.permit(scopes.keys).to_unsafe_h)
  end

  def self.model(model = nil)
    @model ||= model
  end

  def self.scopes
    @scopes ||= {}
  end

  def self.scope(name, options = {}, &block)
    scopes.store(name, options.merge(block: block))
  end
end
