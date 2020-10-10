# frozen_string_literal: true

module YeSQL
  module Errors
    module OutputArgumentError
      def validate_output_options(output)
        return if output.nil?

        raise ArgumentError, format(MESSAGE, output) unless OPTIONS.include?(output.to_sym)
      end

      MESSAGE = <<~MSG
        Unsupported `output` option given `%s`. Possible values are:
          - `columns`: returns an array with the columns from the result.
          - `hash`: returns an array of hashes combining both, the columns and rows from the statement result.
          - `rows`: returns an array of arrays for each row from the given SQL statement.
      MSG
      OPTIONS = %i[columns hash rows].freeze
      private_constant :MESSAGE, :OPTIONS
    end
  end
end
