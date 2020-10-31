# frozen_string_literal: true

require 'yesql'
require 'yesql/common/adapter'

module ::YeSQL
  module Bindings
    class Extract
      include ::YeSQL::Common::Adapter

      def initialize(indexed_bindings, hash, index, value)
        @indexed_bindings = indexed_bindings
        @hash = hash
        @index = index
        @value = value
      end

      def bind_vals
        return [nil, value] unless array?

        value.map { |bind| [nil, bind] }
      end

      def bind_vars
        if mysql?
          return '?' unless array?

          Array.new(value.size, '?').join(', ')
        elsif pg?
          return "$#{last_val}" unless array?

          value.map.with_index(bind_index) { |_, i| "$#{i}" }.join(', ')
        end
      end

      def last_val
        prev_last_val + current_val_size
      end

      def prev
        return if first?

        indexed_bindings[index - 2].first
      end

      private

      attr_reader :hash, :index, :indexed_bindings, :value

      def current_val_size
        return value.size if array?

        1
      end

      def prev_last_val
        return 0 if first?

        hash[prev][:last_val]
      end

      def first?
        index == 1
      end

      def array?
        value.is_a?(Array)
      end

      def bind_index
        return 1 if first?

        prev_last_val + 1
      end
    end
  end
end
