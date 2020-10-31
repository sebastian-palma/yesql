# frozen_string_literal: true

require 'yesql/statement'
require 'yesql/version'
require 'yesql/config/configuration'
require 'yesql/query/performer'
require 'yesql/errors/cache_expiration_error'
require 'yesql/errors/file_path_does_not_exist_error'
require 'yesql/errors/no_bindings_provided_error'
require 'yesql/errors/output_argument_error'

module YeSQL
  include ::YeSQL::Config
  include ::YeSQL::Errors::CacheExpirationError
  include ::YeSQL::Errors::FilePathDoesNotExistError
  include ::YeSQL::Errors::NoBindingsProvidedError
  include ::YeSQL::Errors::OutputArgumentError

  BIND_REGEX = /(?<!:):(\w+)(?=\b)/.freeze

  # rubocop:disable Naming/MethodName
  def YeSQL(file_path, bindings = {}, options = {})
    output = options[:output] || :rows
    cache = options[:cache] || {}

    validate(bindings, cache, file_path, output)
    execute(bindings, cache, file_path, output, options)
  end
  # rubocop:enable Naming/MethodName

  private

  def validate(bindings, cache, file_path, output)
    validate_file_path_existence(file_path)
    validate_statement_bindings(bindings, file_path)
    validate_output_options(output)
    validate_cache_expiration(cache[:expires_in]) unless cache.empty?
  end

  def execute(bindings, cache, file_path, output, options)
    ::YeSQL::Query::Performer.new(
      bindings: bindings,
      bind_statement: ::YeSQL::Statement.new(bindings, file_path),
      cache: cache,
      file_path: file_path,
      output: output,
      prepare: options[:prepare]
    ).call
  end
end
