# frozen_string_literal: true

require 'yesql/utils/read'
require 'yesql/bindings/extractor'

module YeSQL
  module Bindings
    class Binder
      def self.bind_statement(file_path, bindings)
        ::YeSQL::Bindings::Extractor.new(bindings: bindings).call.tap do |extractor|
          break ::YeSQL::Utils::Read.statement(file_path, readable: true)
                                    .gsub(::YeSQL::BIND_REGEX) do |match|
                                      extractor[match[/(\w+)/].to_sym][:bind][:vars]
                                    end
        end
      end
    end
  end
end
