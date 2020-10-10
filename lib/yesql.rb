# frozen_string_literal: true

require 'dry-configurable'
require 'pry'
require 'yesql/version'
require 'yesql/query/performer'
require 'yesql/errors/cache_expiration_error'
require 'yesql/errors/file_path_does_not_exist_error'
require 'yesql/errors/no_bindings_provided_error'
require 'yesql/errors/output_argument_error'
require 'yesql/bindings/binder'

module YeSQL
  extend ::Dry::Configurable

  include ::YeSQL::Errors::CacheExpirationError
  include ::YeSQL::Errors::FilePathDoesNotExistError
  include ::YeSQL::Errors::NoBindingsProvidedError
  include ::YeSQL::Errors::OutputArgumentError

  setting :path, 'app/yesql'

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
      bind_statement: ::YeSQL::Bindings::Binder.bind_statement(file_path, bindings),
      cache: cache,
      file_path: file_path,
      output: output,
      prepare: options[:prepare]
    ).call
  end
end
