# frozen_string_literal: true

require 'yesql'
require 'forwardable'

module ::YeSQL
  module Query
    class TransformResult
      extend Forwardable

      def initialize(output:, result:)
        @output = output
        @result = result
      end

      def call
        if ::Rails::VERSION::MAJOR == 5
          return columns if columns?
          return rows_values if rows?
        end

        return result.public_send(output.to_sym) if columns? || rows?

        array_of_symbol_hashes
      end

      private

      attr_reader :output, :result

      def_delegators(:result, :rows, :to_a)
      def_delegators(:output, :columns?, :hash?, :rows?)

      def rows_values
        to_a.map { |e| e.respond_to?(:values) ? e.values : e }
      end

      def array_of_symbol_hashes
        to_a.tap { |rows| break hashed_rows(rows) if ::Rails::VERSION::MAJOR == 5 }
            .map { |e| e.respond_to?(:symbolize_keys) ? e.symbolize_keys : e }
      end

      def hashed_rows(rows)
        rows.map { |row| columns.zip(row).to_h }
      end

      def columns
        return result.fields if result.respond_to?(:fields)

        result.columns
      end
    end
  end
end
