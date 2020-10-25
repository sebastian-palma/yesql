# frozen_string_literal: true

require 'yesql'
require 'yesql/bindings/utils'
require 'yesql/common/adapter'
require 'yesql/bindings/transformed'
require 'yesql/query/result'
require 'yesql/query/transform_result'
require 'yesql/params/output'

module YeSQL
  module Query
    class Performer
      include ::YeSQL::Bindings::Utils

      # rubocop:disable Metrics/ParameterLists
      def initialize(bind_statement:,
                     bindings: {},
                     cache: {},
                     file_path:,
                     output: :rows,
                     prepare: false)
        @bind_statement = bind_statement
        @cache = cache
        @cache_key = cache[:key] || file_path
        @expires_in = cache[:expires_in]
        @file_path = file_path
        @named_bindings = bindings.transform_keys(&:to_sym)
        @output = ::YeSQL::Params::Output.new(output)
        @prepare = prepare
      end
      # rubocop:enable Metrics/ParameterLists

      def call
        return modified_output if cache.empty?

        Rails.cache.fetch(cache_key, expires_in: expires_in) { modified_output }
      end

      private

      attr_reader :bind_statement,
                  :cache,
                  :cache_key,
                  :expires_in,
                  :file_path,
                  :named_bindings,
                  :output,
                  :prepare,
                  :rows

      def modified_output
        @modified_output ||=
          ::YeSQL::Query::TransformResult.new(output: output, result: query_result).call
      end

      def query_result
        @query_result ||= ::YeSQL::Query::Result.new(binds: binds,
                                                     bind_statement: bind_statement,
                                                     file_path: file_path,
                                                     prepare: prepare).call
      end

      def extractor
        ::YeSQL::Bindings::Extractor.new(bindings: named_bindings).call
      end

      def binds
        ::YeSQL::Bindings::Transformed.new(statement_binds: statement_binds(extractor)).call
      end
    end
  end
end
