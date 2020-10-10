# frozen_string_literal: true

module YeSQL
  module Bindings
    module Utils
      def statement_binds(extractor)
        ::YeSQL::Utils::Read.statement(file_path, readable: true)
                            .scan(::YeSQL::BIND_REGEX).map do |(bind)|
          extractor[bind.to_sym][:bind].values_at(:vals, :vars)
        end
      end
    end
  end
end
