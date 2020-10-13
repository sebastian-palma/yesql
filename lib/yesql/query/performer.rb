# frozen_string_literal: true

require 'yesql'
require 'forwardable'
require 'yesql/bindings/utils'

module YeSQL
  module Query
    class Performer
      extend Forwardable

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
        @connection = ActiveRecord::Base.connection
        @expires_in = cache[:expires_in]
        @file_path = file_path
        @named_bindings = bindings.transform_keys(&:to_sym)
        @output = output
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
                  :connection,
                  :expires_in,
                  :file_path,
                  :named_bindings,
                  :output,
                  :prepare,
                  :rows

      def_delegator(:query_result, :columns)
      private :columns
      def_delegator(:query_result, :rows)
      private :rows

      def modified_output
        @modified_output ||=
          begin
            return query_result.public_send(output) if %w[columns rows].include?(output.to_s)

            columns.map(&:to_sym).tap { |cols| break rows.map { |row| cols.zip(row).to_h } }
          end
      end

      def query_result
        @query_result ||= connection.exec_query(bind_statement, file_path, binds, prepare: prepare)
      end

      def binds
        ::YeSQL::Bindings::Extractor.new(bindings: named_bindings).call.tap do |extractor|
          break statement_binds(extractor).sort_by(&:last)
                                          .uniq
                                          .map(&:first)
                                          .flatten
                                          .each_slice(2)
                                          .to_a
        end
      end
    end
  end
end
