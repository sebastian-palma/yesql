# frozen_string_literal: true

require 'yesql'
require 'yesql/common/adapter'

module ::YeSQL
  module Bindings
    class Transformed
      include ::YeSQL::Common::Adapter

      def initialize(statement_binds:)
        @statement_binds = statement_binds
      end

      def call
        return mysql_rails5_binds if rails5? && mysql?
        return mysql_binds if !rails5? && mysql?

        pg_binds
      end

      private

      attr_reader :statement_binds

      def rails5?
        ::Rails::VERSION::MAJOR == 5
      end

      def mysql_rails5_binds
        statement_binds
          .map(&:first)
          .flatten(1)
          .each_slice(2)
          .flat_map do |first, last|
            next [first, last].map(&:last) if first.is_a?(Array)

            last
          end
      end

      def mysql_binds
        statement_binds
          .map(&:first)
          .flatten
          .each_slice(2)
          .to_a
      end

      def pg_binds
        statement_binds
          .sort_by { |_, position| position.to_s.tr('$', '').to_i }
          .uniq
          .map(&:first)
          .flatten
          .each_slice(2)
          .to_a
      end
    end
  end
end
