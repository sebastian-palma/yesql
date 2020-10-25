# frozen_string_literal: true

require 'yesql'
require 'forwardable'

module ::YeSQL
  module Params
    class Output
      extend Forwardable

      def initialize(output)
        @output = output.to_s
      end

      def columns?
        output == 'columns'
      end

      def rows?
        output == 'rows'
      end

      def hash?
        output == 'hash'
      end

      def_delegator(:output, :to_sym)

      private

      attr_reader :output
    end
  end
end
