# frozen_string_literal: true

require 'yesql/utils/read'

module ::YeSQL
  module Errors
    module NoBindingsProvidedError
      def validate_statement_bindings(binds, file_path)
        return unless statement_binds(file_path).size.positive?

        format(MESSAGE, renderable_statement_binds(file_path)).tap do |message|
          raise ::ArgumentError, message unless binds.is_a?(::Hash) && !binds.empty?
        end
      end

      private

      MESSAGE = <<~MSG

        YeSQL invoked without bindings.

        Expected bindings are:

        %s
      MSG
      private_constant :MESSAGE

      def statement_binds(file_path)
        ::YeSQL::Utils::Read.statement(file_path)
                            .scan(::YeSQL::BIND_REGEX).tap do |scanned_binds|
          break [] if scanned_binds.size.zero?

          break scanned_binds.sort
        end
      end

      def renderable_statement_binds(file_path)
        statement_binds(file_path).flatten.map { |bind| "- `#{bind}`\n" }.join
      end
    end
  end
end
