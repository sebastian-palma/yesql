# frozen_string_literal: true

require 'yesql/bindings/extract'

module YeSQL
  module Bindings
    class Extractor
      def initialize(bindings:)
        @bindings = bindings
        @indexed_bindings = (bindings || {}).to_a
      end

      # rubocop:disable Metrics/MethodLength
      def call
        bindings.each_with_object({}).with_index(1) do |((key, value), hash), index|
          hash[key] =
            ::YeSQL::Bindings::Extract.new(indexed_bindings, hash, index, value).tap do |extract|
              break {
                bind: {
                  vals: extract.bind_vals,
                  vars: extract.bind_vars
                },
                last_val: extract.last_val,
                match: key,
                prev: extract.prev,
                value: value
              }
            end
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      attr_reader :bindings, :indexed_bindings
    end
  end
end
